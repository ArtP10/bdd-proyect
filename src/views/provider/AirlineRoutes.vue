<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">
        <span class="icon">+</span> Nueva Ruta
      </button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Transporte</th>
          <th>Enfoque</th> <th>Origen</th>
          <th>Destino</th>
          <th>Costo ($)</th>
          <th>Millas</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="route in routes" :key="route.rut_codigo">
          <td>#{{ route.rut_codigo }}</td>
          
          <td>
            <span class="type-icon">
                <i class="fa-solid fa-plane-up"></i> {{ route.rut_tipo }}
            </span>
          </td>

          <td>
            <span :class="['badge', getBadgeClass(route.rut_descripcion)]">
                {{ route.rut_descripcion || 'General' }}
            </span>
          </td>

          <td class="font-bold">{{ route.origen_nombre }}</td>
          <td class="font-bold">{{ route.destino_nombre }}</td>
          <td>${{ route.rut_costo }}</td>
          <td>{{ route.rut_millas_otorgadas }}</td>
          <td>
            <button @click="openEditModal(route)" class="btn-sm">Editar</button>
            <button @click="deleteRoute(route.rut_codigo)" class="btn-danger-sm">Eliminar</button>
          </td>
        </tr>
        <tr v-if="routes.length === 0">
            <td colspan="8" class="empty-cell">No hay rutas registradas.</td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Modificar Ruta' : 'Crear Nueva Ruta' }}</h3>
        <form @submit.prevent="saveRoute">
          
          <div class="form-group">
            <label>Enfoque de la Ruta</label>
            <select v-model="form.rut_descripcion" required :disabled="isEditing">
                <option value="" disabled>Seleccione una opción</option>
                <option value="Familiar">Familiar</option>
                <option value="Corporativo">Corporativo</option>
                <option value="Explorador">Explorador</option>
                <option value="Practico">Práctico</option>
                <option value="Comfort">Comfort</option>
            </select>
          </div>

          <div class="form-group">
            <label>Terminal Origen</label>
            <select v-model="form.fk_origen" required :disabled="isEditing">
                <option value="" disabled>Seleccione Origen</option>
                <option v-for="t in terminals" :key="t.ter_codigo" :value="t.ter_codigo">
                    {{ t.ter_nombre_completo }}
                </option>
            </select>
          </div>

          <div class="form-group">
            <label>Terminal Destino</label>
            <select v-model="form.fk_destino" required :disabled="isEditing">
                <option value="" disabled>Seleccione Destino</option>
                <option v-for="t in filteredDestinals" :key="t.ter_codigo" :value="t.ter_codigo">
                    {{ t.ter_nombre_completo }}
                </option>
            </select>
          </div>

          <div class="form-row">
            <div class="form-group">
                <label>Costo Base ($)</label>
                <input type="number" v-model.number="form.costo" min="0" step="0.01" required />
            </div>
            <div class="form-group">
                <label>Millas Otorgadas</label>
                <input type="number" v-model.number="form.millas" min="0" required />
            </div>
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">
                {{ isEditing ? 'Guardar Cambios' : 'Registrar Ruta' }}
            </button>
            <button type="button" @click="closeModal" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';

const routes = ref([]);
const terminals = ref([]);
const showModal = ref(false);
const isEditing = ref(false);
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

const form = reactive({
    rut_codigo: null,
    fk_origen: '',
    fk_destino: '',
    rut_descripcion: '', 
    costo: 0,
    millas: 0,
    rut_tipo: 'Aerea'
});

const filteredDestinals = computed(() => {
    if (!form.fk_origen) return terminals.value;
    return terminals.value.filter(t => t.ter_codigo !== form.fk_origen);
});

// Función para asignar colores según el tipo
const getBadgeClass = (desc) => {
    const map = {
        'Familiar': 'badge-orange',
        'Corporativo': 'badge-blue',
        'Explorador': 'badge-green',
        'Practico': 'badge-gray',
        'Comfort': 'badge-purple'
    };
    return map[desc] || 'badge-gray';
};

// --- API Calls ---
const fetchTerminals = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/routes/terminals', {
            method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) terminals.value = data.data;
    } catch(e) { console.error(e); }
};

const fetchRoutes = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/routes/list', {
            method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) routes.value = data.data;
    } catch(e) { console.error(e); }
};

const saveRoute = async () => {
    if (!isEditing.value && form.fk_origen === form.fk_destino) {
        alert("El origen y el destino no pueden ser iguales");
        return;
    }

    try {
        let url = 'http://localhost:3000/api/users/providers/routes/create';
        // Payload para CREAR (Incluye descripción)
        let payload = { 
            user_id: userSession.user_id,
            fk_origen: form.fk_origen,
            fk_destino: form.fk_destino,
            costo: form.costo,
            millas: form.millas,
            rut_tipo: 'Aerea',
            rut_descripcion: form.rut_descripcion 
        };

        if (isEditing.value) {
            url = 'http://localhost:3000/api/users/providers/routes/update';
            // Payload para EDITAR (Ahora incluimos descripción también por si quieres permitir cambiarla)
            payload = {
                user_id: userSession.user_id,
                rut_codigo: form.rut_codigo,
                costo: form.costo,
                millas: form.millas,
                rut_descripcion: form.rut_descripcion // Agregado para permitir update
            };
        }

        const res = await fetch(url, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert(isEditing.value ? 'Ruta actualizada' : 'Ruta creada exitosamente');
            closeModal();
            fetchRoutes();
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

const deleteRoute = async (id) => {
    if(!confirm('¿Seguro que desea eliminar esta ruta? Solo es posible si no hay vuelos activos.')) return;
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/routes/delete', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id, rut_codigo: id })
        });
        const data = await res.json();
        if(data.success) {
            alert('Ruta eliminada');
            fetchRoutes();
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// --- Modal Logic ---
const openCreateModal = () => {
    fetchTerminals();
    isEditing.value = false;
    form.rut_codigo = null;
    form.fk_origen = '';
    form.fk_destino = '';
    form.rut_descripcion = ''; 
    form.costo = 0;
    form.millas = 0;
    showModal.value = true;
};

const openEditModal = (route) => {
    isEditing.value = true;
    form.rut_codigo = route.rut_codigo;
    form.costo = route.rut_costo;
    form.millas = route.rut_millas_otorgadas;
    form.rut_descripcion = route.rut_descripcion; 
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
};

onMounted(() => {
    fetchRoutes();
});
</script>

<style scoped>
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: separate; border-spacing: 0; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); }
.data-table th, .data-table td { padding: 16px; text-align: left; border-bottom: 1px solid #e2e8f0; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; text-transform: uppercase; font-size: 0.75rem; }
.font-bold { font-weight: 600; color: #1e293b; }
.empty-cell { text-align: center; color: #94a3b8; font-style: italic; padding: 2rem; }

/* Estilos de Badges */
.badge { padding: 4px 10px; border-radius: 99px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; display: inline-block; }
.badge-blue { background: #e0f2fe; color: #0369a1; }
.badge-green { background: #dcfce7; color: #15803d; }
.badge-orange { background: #ffedd5; color: #c2410c; }
.badge-purple { background: #f3e8ff; color: #7e22ce; }
.badge-gray { background: #f1f5f9; color: #475569; }

.type-icon { color: #64748b; font-weight: 600; }

.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; }
.btn-sm { padding: 6px 12px; font-size: 0.85rem; border: 1px solid #cbd5e1; background: white; border-radius: 4px; cursor: pointer; margin-right: 5px; }
.btn-danger-sm { padding: 6px 12px; font-size: 0.85rem; border: 1px solid #fecaca; background: #fee2e2; color: #991b1b; border-radius: 4px; cursor: pointer; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; margin-left: 10px; }

.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 50; }
.modal-content { background: white; padding: 30px; border-radius: 12px; width: 500px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #64748b; font-size: 0.9rem; }
.form-group input, .form-group select { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 1rem; box-sizing: border-box; }
.form-group select:disabled { background-color: #f1f5f9; cursor: not-allowed; }
.form-row { display: flex; gap: 15px; }
.form-row .form-group { flex: 1; }
.modal-actions { display: flex; justify-content: flex-end; margin-top: 25px; }
</style>