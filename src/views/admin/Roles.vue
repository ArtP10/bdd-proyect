<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">+ Nuevo Rol</button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>Código</th>
          <th>Nombre</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="rol in roles" :key="rol.rol_codigo">
          <td>{{ rol.rol_codigo }}</td>
          <td><strong>{{ rol.rol_nombre }}</strong></td>
          <td class="desc-cell">{{ rol.rol_descripcion }}</td>
          <td>
            <button class="btn-sm" @click="editarRol(rol)">✏️ Editar</button>
            <button class="btn-danger-sm" @click="eliminarRol(rol.rol_codigo)">🗑️ Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Editar' : 'Registrar' }} Rol</h3>
        <form @submit.prevent="saveRol">
          
          <div class="form-section">
            <div class="form-group">
                <label>Nombre del Rol</label>
                <input v-model="form.nombre" required placeholder="Ej: Administrador" />
            </div>
            
            <div class="form-group">
                <label>Descripción</label>
                <textarea v-model="form.descripcion" rows="3" placeholder="Descripción del rol..."></textarea>
            </div>
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">{{ isEditing ? 'Actualizar' : 'Registrar' }}</button>
            <button type="button" @click="cerrarModal" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

// --- ESTADO GENERAL ---
const API_URL = 'http://localhost:3000/api/roles';
const roles = ref([]);

// --- ESTADO MODAL CREAR/EDITAR ---
const showModal = ref(false);
const isEditing = ref(false);
const form = reactive({ codigo: null, nombre: '', descripcion: '' });

// --- API FETCH ---
const fetchRoles = async () => {
    try {
        const res = await axios.get(API_URL);
        roles.value = res.data; 
    } catch(e) { console.error("Error fetching roles:", e); }
};

// --- LOGICA CRUD ---
const saveRol = async () => {
    try {
        if (isEditing.value) {
            await axios.put(`${API_URL}/${form.codigo}`, form);
            alert('Rol actualizado');
        } else {
            await axios.post(API_URL, form);
            alert('Rol creado');
        }
        cerrarModal();
        fetchRoles();
    } catch(e) { 
        console.error(e); 
        alert('Error al guardar: ' + (e.response?.data?.error || e.message));
    }
};

const eliminarRol = async (id) => {
    if(!confirm('¿Estás seguro de eliminar este rol?')) return;
    try {
        await axios.delete(`${API_URL}/${id}`);
        fetchRoles();
    } catch(e) { console.error(e); alert('Error al eliminar'); }
};

// --- MODAL CONTROLS ---
const openCreateModal = () => {
    isEditing.value = false;
    Object.assign(form, { codigo: null, nombre: '', descripcion: '' });
    showModal.value = true;
};

const editarRol = (rol) => {
    isEditing.value = true;
    Object.assign(form, {
        codigo: rol.rol_codigo,
        nombre: rol.rol_nombre,
        descripcion: rol.rol_descripcion
    });
    showModal.value = true;
};

const cerrarModal = () => {
    showModal.value = false;
};

onMounted(() => {
    fetchRoles();
});
</script>

<style scoped>
/* ESTILOS GENERALES (Reutilizados de Promotions.vue) */
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; }

.desc-cell { max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #64748b; }

/* BOTONES */
.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #2563eb; }
.btn-secondary { background: #94a3b8; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }

.btn-sm { padding: 5px 10px; font-size: 0.8rem; margin-right: 5px; cursor: pointer; background: #e2e8f0; border: none; border-radius: 4px; }
.btn-danger-sm { padding: 5px 10px; font-size: 0.8rem; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; border-radius: 4px; margin-right: 5px; }

/* MODAL */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-height: 90vh; overflow-y: auto; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }

.form-section { margin-bottom: 15px; }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; color: #334155; }
.form-group input, .form-group textarea { width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 4px; box-sizing: border-box; font-family: inherit; }
.form-group textarea { resize: vertical; }

.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; border-top: 1px solid #eee; padding-top: 15px; }
</style>
