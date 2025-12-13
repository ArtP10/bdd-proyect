<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">
        <span class="icon">✈️</span> Programar Vuelo
      </button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Ruta</th>
          <th>Aeronave</th>
          <th>Salida</th>
          <th>Llegada</th>
          <th>Estado</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="t in travels" :key="t.tras_codigo">
          <td>#{{ t.tras_codigo }}</td>
          <td class="font-bold">{{ t.ruta_nombre }}</td>
          <td>
            {{ t.transporte_nombre }}
            <br><small class="text-muted">Cap: {{ t.med_tra_capacidad }} pax</small>
          </td>
          <td>{{ formatDate(t.tras_fecha_hora_inicio) }}</td>
          <td>{{ formatDate(t.tras_fecha_hora_fin) }}</td>
          <td>
            <span :class="getStatusClass(t.estado_traslado)">
              {{ t.estado_traslado }}
            </span>
          </td>
          <td>
            <button v-if="t.estado_traslado !== 'Finalizado'" 
                    @click="openEditModal(t)" 
                    class="btn-sm">
              Reprogramar
            </button>
            <span v-else class="text-muted text-sm">--</span>
          </td>
        </tr>
        <tr v-if="travels.length === 0">
            <td colspan="7" class="empty-cell">No hay vuelos programados.</td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Reprogramar Vuelo' : 'Programar Nuevo Vuelo' }}</h3>
        <form @submit.prevent="saveTravel">
          
          <div class="form-group">
            <label>Ruta</label>
            <select v-model="form.rut_codigo" required :disabled="isEditing">
                <option value="" disabled>Seleccione una Ruta</option>
                <option v-for="r in routesList" :key="r.rut_codigo" :value="r.rut_codigo">
                    {{ r.origen_nombre }} ➝ {{ r.destino_nombre }}
                </option>
            </select>
          </div>

          <div class="form-group">
            <label>Aeronave</label>
            <select v-model="form.med_tra_codigo" required :disabled="isEditing">
                <option value="" disabled>Seleccione un Avión</option>
                <option v-for="p in fleetList" :key="p.med_tra_codigo" :value="p.med_tra_codigo">
                    {{ p.med_tra_descripcion }} ({{ p.med_tra_capacidad }} pax)
                </option>
            </select>
          </div>

          <div class="form-row">
            <div class="form-group">
                <label>Fecha/Hora Salida</label>
                <input type="datetime-local" v-model="form.fecha_inicio" required />
            </div>
            <div class="form-group">
                <label>Fecha/Hora Llegada</label>
                <input type="datetime-local" v-model="form.fecha_fin" required />
            </div>
          </div>

          <div class="form-group" v-if="!isEditing">
            <label>Emisión CO2 (kg estimado)</label>
            <input type="number" v-model.number="form.co2" step="0.01" min="0" required />
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">
                {{ isEditing ? 'Actualizar Horario' : 'Programar' }}
            </button>
            <button type="button" @click="closeModal" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';

const travels = ref([]);
const routesList = ref([]);
const fleetList = ref([]);
const showModal = ref(false);
const isEditing = ref(false);
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

const form = reactive({
    tras_codigo: null,
    rut_codigo: '',
    med_tra_codigo: '',
    fecha_inicio: '',
    fecha_fin: '',
    co2: 0
});

// --- Helpers ---
const formatDate = (isoString) => {
    if (!isoString) return '';
    return new Date(isoString).toLocaleString();
};

const getStatusClass = (status) => {
    switch(status) {
        case 'En Curso': return 'badge badge-green';
        case 'Programado': return 'badge badge-blue';
        case 'Finalizado': return 'badge badge-gray';
        default: return 'badge';
    }
};

// Convierte fecha ISO de BD a formato input datetime-local (YYYY-MM-DDTHH:mm)
const toInputDate = (isoString) => {
    if (!isoString) return '';
    const d = new Date(isoString);
    d.setMinutes(d.getMinutes() - d.getTimezoneOffset());
    return d.toISOString().slice(0, 16);
};

// --- API Calls ---

const fetchData = async () => {
    const payload = { user_id: userSession.user_id };
    
    // 1. Obtener Viajes
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/travels/list', {
            method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload)
        });
        const data = await res.json();
        if(data.success) travels.value = data.data;
    } catch(e) { console.error(e); }

    // 2. Obtener Rutas (Para el select)
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/routes/list', {
            method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload)
        });
        const data = await res.json();
        if(data.success) routesList.value = data.data;
    } catch(e) { console.error(e); }

    // 3. Obtener Flota (Para el select)
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/fleet/list', {
            method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload)
        });
        const data = await res.json();
        if(data.success) fleetList.value = data.data;
    } catch(e) { console.error(e); }
};

const saveTravel = async () => {
    if (new Date(form.fecha_inicio) >= new Date(form.fecha_fin)) {
        alert("La fecha de llegada debe ser posterior a la de salida.");
        return;
    }

    try {
        const endpoint = isEditing.value ? 'update' : 'create';
        const payload = { 
            user_id: userSession.user_id,
            ...form
        };

        const res = await fetch(`http://localhost:3000/api/users/providers/travels/${endpoint}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert(isEditing.value ? 'Vuelo reprogramado' : 'Vuelo programado exitosamente');
            closeModal();
            fetchData(); // Recargar tabla
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// --- Modal Logic ---

const openCreateModal = () => {
    isEditing.value = false;
    form.tras_codigo = null;
    form.rut_codigo = '';
    form.med_tra_codigo = '';
    form.fecha_inicio = '';
    form.fecha_fin = '';
    form.co2 = 0;
    showModal.value = true;
};

const openEditModal = (t) => {
    isEditing.value = true;
    form.tras_codigo = t.tras_codigo;
    // Solo cargamos fechas para editar, el resto es visual/disabled
    form.fecha_inicio = toInputDate(t.tras_fecha_hora_inicio);
    form.fecha_fin = toInputDate(t.tras_fecha_hora_fin);
    // Cargamos estos solo para que el select se vea bonito aunque esté disabled
    // Nota: Necesitaríamos buscar los IDs originales en la lista si quisieramos que el select cuadre perfecto
    // Pero como es disabled, con mostrarlo basta.
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
};

onMounted(() => {
    fetchData();
});
</script>

<style scoped>
/* Reutilizando estilos previos */
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: separate; border-spacing: 0; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.data-table th, .data-table td { padding: 16px; text-align: left; border-bottom: 1px solid #e2e8f0; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; text-transform: uppercase; font-size: 0.75rem; }
.font-bold { font-weight: 600; color: #1e293b; }
.text-muted { color: #64748b; font-size: 0.85rem; }
.empty-cell { text-align: center; color: #94a3b8; font-style: italic; padding: 2rem; }

.badge { padding: 4px 10px; border-radius: 99px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
.badge-green { background: #dcfce7; color: #166534; }
.badge-blue { background: #dbeafe; color: #1e40af; }
.badge-gray { background: #f1f5f9; color: #475569; }

.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }
.btn-sm { padding: 5px 10px; font-size: 0.8rem; border: 1px solid #cbd5e1; background: white; border-radius: 4px; cursor: pointer; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; margin-left: 10px; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 50; }
.modal-content { background: white; padding: 30px; border-radius: 12px; width: 500px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #64748b; font-size: 0.9rem; }
.form-group input, .form-group select { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 1rem; box-sizing: border-box; }
.form-group input:disabled, .form-group select:disabled { background-color: #f1f5f9; cursor: not-allowed; }
.form-row { display: flex; gap: 15px; }
.form-row .form-group { flex: 1; }
.modal-actions { display: flex; justify-content: flex-end; margin-top: 25px; }
</style>