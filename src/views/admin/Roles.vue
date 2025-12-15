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
            <button class="btn-warning-sm" @click="openPrivilegesModal(rol)">🔑 Privilegios</button>
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

    <div v-if="showPrivModal" class="modal-overlay">
      <div class="modal-content modal-lg">
        <h3>Gestionar Privilegios</h3>
        <p class="subtitle">Rol: <strong>{{ selectedRoleName }}</strong></p>
        
        <div class="privilege-list">
          <div v-if="allPrivileges.length === 0" class="empty-state">
            No hay privilegios registrados en el sistema.
          </div>
          
          <label 
            v-for="priv in allPrivileges" 
            :key="priv.pri_codigo" 
            class="privilege-item"
            :class="{ 'selected': selectedPrivilegeIds.includes(priv.pri_codigo) }"
          >
            <input 
              type="checkbox" 
              :value="priv.pri_codigo" 
              v-model="selectedPrivilegeIds" 
            />
            <div class="priv-info">
              <span class="priv-name">{{ priv.pri_nombre }}</span>
              <span class="priv-desc">{{ priv.pri_descripcion }}</span>
            </div>
          </label>
        </div>

        <div class="modal-actions">
          <button type="button" @click="savePrivilegesChanges" class="btn-primary" :disabled="isSavingPrivs">
            {{ isSavingPrivs ? 'Guardando...' : 'Guardar Cambios' }}
          </button>
          <button type="button" @click="cerrarPrivModal" class="btn-secondary">Cerrar</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';
import axios from 'axios';

// --- CONFIGURACIÓN ---
const API_URL = 'http://localhost:3000/api'; // Base URL
const ROLES_URL = `${API_URL}/roles`;
const PRIVS_URL = `${API_URL}/privileges`; // Endpoint para obtener todos los privilegios
const ROL_PRIVS_URL = `${API_URL}/rol-privileges`; // Endpoint para relaciones

// --- ESTADO GENERAL ---
const roles = ref([]);

// --- ESTADO MODAL ROL ---
const showModal = ref(false);
const isEditing = ref(false);
const form = reactive({ codigo: null, nombre: '', descripcion: '' });

// --- ESTADO MODAL PRIVILEGIOS ---
const showPrivModal = ref(false);
const isSavingPrivs = ref(false);
const selectedRoleCode = ref(null);
const selectedRoleName = ref('');
const allPrivileges = ref([]); // Lista maestra de privilegios
const selectedPrivilegeIds = ref([]); // IDs seleccionados en el checkbox (v-model)
const originalPrivilegeIds = ref([]); // Copia para comparar cambios

// --- API FETCH ROLES ---
const fetchRoles = async () => {
    try {
        const res = await axios.get(ROLES_URL);
        roles.value = res.data; 
    } catch(e) { console.error("Error fetching roles:", e); }
};

// --- LOGICA CRUD ROLES ---
const saveRol = async () => {
    try {
        if (isEditing.value) {
            await axios.put(`${ROLES_URL}/${form.codigo}`, form);
            alert('Rol actualizado');
        } else {
            await axios.post(ROLES_URL, form);
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
        await axios.delete(`${ROLES_URL}/${id}`);
        fetchRoles();
    } catch(e) { console.error(e); alert('Error al eliminar'); }
};

// --- MODAL CONTROLS ROL ---
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

// ==========================================
// --- LÓGICA GESTIÓN DE PRIVILEGIOS ---
// ==========================================

const openPrivilegesModal = async (rol) => {
    selectedRoleCode.value = rol.rol_codigo;
    selectedRoleName.value = rol.rol_nombre;
    selectedPrivilegeIds.value = [];
    
    try {
        // 1. Cargar catálogo de privilegios (si no está cargado)
        if (allPrivileges.value.length === 0) {
            const resAll = await axios.get(PRIVS_URL);
            allPrivileges.value = resAll.data;
        }

        // 2. Cargar privilegios asignados a este rol específico
        // Asumiendo endpoint GET /api/roles/:id/privileges o similar
        // Ajusta la URL según tu backend. Aquí uso query param para ejemplo.
        const resAssigned = await axios.get(`${ROL_PRIVS_URL}/${rol.rol_codigo}`);
        
        // Asumiendo que resAssigned.data devuelve array de objetos [{fk_pri_codigo: 1}, ...]
        // Mapeamos solo a IDs
        const ids = resAssigned.data.map(p => p.fk_pri_codigo);
        
        selectedPrivilegeIds.value = [...ids];
        originalPrivilegeIds.value = [...ids]; // Guardamos copia para comparar
        
        showPrivModal.value = true;
    } catch (e) {
        console.error("Error cargando privilegios:", e);
        alert("No se pudieron cargar los privilegios.");
    }
};

const savePrivilegesChanges = async () => {
    isSavingPrivs.value = true;
    try {
        // Calculamos diferencias para ser eficientes
        const currentSet = new Set(selectedPrivilegeIds.value);
        const originalSet = new Set(originalPrivilegeIds.value);

        const toAdd = [...currentSet].filter(x => !originalSet.has(x));
        const toRemove = [...originalSet].filter(x => !currentSet.has(x));

        const promises = [];

        // 1. Agregar nuevos (Llamar a SP asignar_privilegio_rol)
        toAdd.forEach(priId => {
            promises.push(axios.post(`${ROL_PRIVS_URL}`, {
                rol_codigo: selectedRoleCode.value,
                pri_codigo: priId
            }));
        });

        // 2. Eliminar desmarcados (Llamar a SP revocar_privilegio_rol)
        toRemove.forEach(priId => {
            promises.push(axios.delete(`${ROL_PRIVS_URL}`, {
                data: { // Axios delete requiere 'data' body de esta forma
                    rol_codigo: selectedRoleCode.value,
                    pri_codigo: priId
                }
            }));
        });

        await Promise.all(promises);
        
        alert("Privilegios actualizados correctamente.");
        cerrarPrivModal();

    } catch (e) {
        console.error("Error guardando privilegios:", e);
        alert("Ocurrió un error al guardar los cambios.");
    } finally {
        isSavingPrivs.value = false;
    }
};

const cerrarPrivModal = () => {
    showPrivModal.value = false;
    selectedRoleCode.value = null;
};

onMounted(() => {
    fetchRoles();
});
</script>

<style scoped>
/* ESTILOS PREVIOS SE MANTIENEN ... */
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; }
.desc-cell { max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #64748b; }

.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #2563eb; }
.btn-primary:disabled { background: #93c5fd; cursor: not-allowed; }
.btn-secondary { background: #94a3b8; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }

.btn-sm { padding: 5px 10px; font-size: 0.8rem; margin-right: 5px; cursor: pointer; background: #e2e8f0; border: none; border-radius: 4px; }
.btn-danger-sm { padding: 5px 10px; font-size: 0.8rem; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; border-radius: 4px; margin-right: 5px; }
/* Estilo para el nuevo botón de privilegios */
.btn-warning-sm { padding: 5px 10px; font-size: 0.8rem; background: #fef3c7; color: #d97706; border: 1px solid #fcd34d; cursor: pointer; border-radius: 4px; margin-right: 5px; }

.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-height: 90vh; overflow-y: auto; box-shadow: 0 4px 6px rgba(0,0,0,0.1); display: flex; flex-direction: column; }

.modal-lg { width: 600px; } /* Modal más ancho para privilegios */

.form-section { margin-bottom: 15px; }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; color: #334155; }
.form-group input, .form-group textarea { width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 4px; box-sizing: border-box; font-family: inherit; }
.form-group textarea { resize: vertical; }

.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; border-top: 1px solid #eee; padding-top: 15px; }

/* NUEVOS ESTILOS PARA LA LISTA DE PRIVILEGIOS */
.subtitle { margin-top: -10px; margin-bottom: 15px; color: #64748b; font-size: 0.95rem; }
.privilege-list { max-height: 300px; overflow-y: auto; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px; background: #f8fafc; }
.privilege-item { display: flex; align-items: flex-start; padding: 10px; border-bottom: 1px solid #eee; cursor: pointer; transition: background 0.2s; border-radius: 4px; }
.privilege-item:last-child { border-bottom: none; }
.privilege-item:hover { background: #e2e8f0; }
.privilege-item.selected { background: #eff6ff; }
.privilege-item input[type="checkbox"] { margin-top: 5px; margin-right: 12px; transform: scale(1.2); cursor: pointer; }
.priv-info { display: flex; flex-direction: column; }
.priv-name { font-weight: 600; color: #334155; font-size: 0.95rem; }
.priv-desc { font-size: 0.85rem; color: #64748b; }
.empty-state { text-align: center; color: #94a3b8; padding: 20px; font-style: italic; }
</style>