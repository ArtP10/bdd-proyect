<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">
        <span class="icon">+</span> Registrar Avión
      </button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Aeronave / Descripción</th>
          <th>Capacidad</th>
          <th>Estado Actual</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="plane in fleet" :key="plane.med_tra_codigo">
          <td>#{{ plane.med_tra_codigo }}</td>
          <td>{{ plane.med_tra_descripcion }}</td>
          <td>{{ plane.med_tra_capacidad }} pasajeros</td>
          <td>
            <span :class="getStatusClass(plane.estado_actual)">
              {{ plane.estado_actual }}
            </span>
          </td>
          <td>
            <button @click="openEditModal(plane)" class="btn-sm">Editar</button>
            <button @click="deletePlane(plane.med_tra_codigo)" class="btn-danger-sm">Eliminar</button>
          </td>
        </tr>
        <tr v-if="fleet.length === 0">
            <td colspan="5" class="empty-cell">No hay aviones registrados.</td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Modificar Avión' : 'Registrar Nueva Aeronave' }}</h3>
        <form @submit.prevent="savePlane">
          
          <div class="form-group">
            <label>Descripción / Modelo</label>
            <input v-model="form.descripcion" placeholder="Ej: Boeing 737-800" required />
          </div>

          <div class="form-group">
            <label>Capacidad (Puestos)</label>
            <input type="number" v-model.number="form.capacidad" min="1" required />
            <small v-if="isEditing" class="warning-text">
                Nota: Si reduce la capacidad, se eliminarán los puestos con numeración más alta.
            </small>
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">{{ isEditing ? 'Guardar Cambios' : 'Registrar' }}</button>
            <button type="button" @click="closeModal" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';

const fleet = ref([]);
const showModal = ref(false);
const isEditing = ref(false);
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

const form = reactive({
    med_tra_codigo: null,
    capacidad: 100,
    descripcion: ''
});

// Función para determinar el color del tag según el estado del SP
const getStatusClass = (status) => {
    switch(status) {
        case 'En Vuelo': return 'badge badge-green'; // Verde
        case 'En Espera': return 'badge badge-yellow'; // Amarillo
        case 'Inactivo': return 'badge badge-gray'; // Gris
        default: return 'badge';
    }
};

// --- API Calls ---

const fetchFleet = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/fleet/list', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) fleet.value = data.data;
    } catch(e) { console.error(e); }
};

const savePlane = async () => {
    try {
        const endpoint = isEditing.value ? 'update' : 'create';
        const payload = { 
            user_id: userSession.user_id,
            med_tra_codigo: form.med_tra_codigo,
            capacidad: form.capacidad,
            descripcion: form.descripcion
        };

        const res = await fetch(`http://localhost:3000/api/users/providers/fleet/${endpoint}`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert(isEditing.value ? 'Avión actualizado' : 'Avión registrado');
            closeModal();
            fetchFleet();
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

const deletePlane = async (id) => {
    if(!confirm('¿Seguro que desea eliminar este avión? Esta acción no se puede deshacer.')) return;
    
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/fleet/delete', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id, med_tra_codigo: id })
        });
        const data = await res.json();
        if(data.success) {
            alert('Avión eliminado');
            fetchFleet();
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// --- Modal Logic ---
const openCreateModal = () => {
    isEditing.value = false;
    form.med_tra_codigo = null;
    form.capacidad = 100;
    form.descripcion = '';
    showModal.value = true;
};

const openEditModal = (plane) => {
    isEditing.value = true;
    form.med_tra_codigo = plane.med_tra_codigo;
    form.capacidad = plane.med_tra_capacidad;
    form.descripcion = plane.med_tra_descripcion;
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
};

onMounted(() => {
    fetchFleet();
});
</script>

<style scoped>
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: separate; border-spacing: 0; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.data-table th, .data-table td { padding: 16px; text-align: left; border-bottom: 1px solid #e2e8f0; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; text-transform: uppercase; font-size: 0.75rem; letter-spacing: 0.05em; }
.data-table tr:last-child td { border-bottom: none; }
.empty-cell { text-align: center; color: #94a3b8; font-style: italic; padding: 2rem; }

/* Badges (Tags) Styles */
.badge { padding: 6px 12px; border-radius: 9999px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; display: inline-block; }
.badge-green { background-color: #dcfce7; color: #166534; border: 1px solid #bbf7d0; } /* En Vuelo */
.badge-yellow { background-color: #fef9c3; color: #854d0e; border: 1px solid #fde047; } /* En Espera */
.badge-gray { background-color: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; } /* Inactivo */

/* Buttons */
.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; display: inline-flex; align-items: center; gap: 8px; box-shadow: 0 2px 4px rgba(59, 130, 246, 0.3); transition: 0.2s; }
.btn-primary:hover { background: #2563eb; transform: translateY(-1px); }
.btn-sm { padding: 6px 12px; font-size: 0.85rem; border: 1px solid #cbd5e1; background: white; color: #334155; border-radius: 4px; cursor: pointer; margin-right: 8px; transition: 0.2s; }
.btn-sm:hover { border-color: #94a3b8; background: #f8fafc; }
.btn-danger-sm { padding: 6px 12px; font-size: 0.85rem; border: 1px solid #fecaca; background: #fee2e2; color: #991b1b; border-radius: 4px; cursor: pointer; transition: 0.2s; }
.btn-danger-sm:hover { background: #fecaca; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; margin-left: 10px; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 50; backdrop-filter: blur(2px); }
.modal-content { background: white; padding: 30px; border-radius: 12px; width: 450px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); }
.modal-content h3 { margin-top: 0; color: #1e293b; margin-bottom: 20px; font-size: 1.25rem; }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #64748b; font-size: 0.9rem; }
.form-group input { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 1rem; transition: border-color 0.2s; box-sizing: border-box; }
.form-group input:focus { border-color: #3b82f6; outline: none; }
.warning-text { color: #d97706; font-size: 0.8rem; margin-top: 4px; display: block; }
.modal-actions { display: flex; justify-content: flex-end; margin-top: 25px; }
</style>