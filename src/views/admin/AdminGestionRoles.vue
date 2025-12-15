<template>
  <div class="container-fluid">
    <div class="header-actions">
      <div>
        <h2>🛡️ Gestión de Roles</h2>
        <p class="subtitle">Administra los roles y permisos de acceso</p>
      </div>
      <button @click="openCreateModal" class="btn-main">
        <span>+</span> Nuevo Rol
      </button>
    </div>

    <div class="table-card">
      <table class="styled-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nombre del Rol</th>
            <th>Descripción</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="r in roles" :key="r.rol_codigo">
            <td><span class="id-tag">#{{ r.rol_codigo }}</span></td>
            <td class="font-bold">{{ r.rol_nombre }}</td>
            <td class="text-muted">{{ r.rol_descripcion }}</td>
            <td class="text-center">
              <div class="action-group">
                <button class="action-btn btn-edit" @click="openEditModal(r)" title="Editar">
                  ✏️
                </button>
                <button class="action-btn btn-delete" @click="deleteRol(r.rol_codigo)" title="Eliminar">
                  🗑️
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="roles.length === 0">
              <td colspan="4" class="empty-text">
                  <div class="empty-state">No hay roles registrados.</div>
              </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showModal" class="modal-backdrop" @click.self="showModal=false">
      <div class="modal-window slide-in">
        <div class="modal-header">
            <h3>{{ isEditing ? '✏️ Editar Rol' : '🛡️ Nuevo Rol' }}</h3>
            <button class="close-icon" @click="showModal=false">✕</button>
        </div>
        <form @submit.prevent="saveRol">
          <div class="modal-body">
            <div class="form-group">
                <label>Nombre del Rol</label>
                <input v-model="form.nombre" required placeholder="Ej: Administrador" class="input-field" />
            </div>
            <div class="form-group">
                <label>Descripción</label>
                <textarea v-model="form.descripcion" required placeholder="Descripción de permisos..." class="input-field" rows="3"></textarea>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" @click="showModal=false" class="btn-secondary">Cancelar</button>
            <button type="submit" class="btn-main">{{ isEditing ? 'Actualizar' : 'Guardar' }}</button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';

const API_URL = 'http://localhost:3000/api/roles'; // Asegúrate que coincida con tu backend

const roles = ref([]);
const showModal = ref(false);
const isEditing = ref(false);
const form = reactive({ id: null, nombre: '', descripcion: '' });

const fetchRoles = async () => {
    try {
        const res = await fetch(API_URL);
        const data = await res.json();
        if(data.success) roles.value = data.data;
    } catch(e) { console.error(e); }
};

const saveRol = async () => {
    try {
        const url = isEditing.value ? `${API_URL}/${form.id}` : API_URL;
        const method = isEditing.value ? 'PUT' : 'POST';
        const res = await fetch(url, {
            method: method,
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(form)
        });
        const data = await res.json();
        if(data.success) {
            showModal.value = false;
            fetchRoles();
        } else {
            alert(data.message);
        }
    } catch(e) { console.error(e); }
};

const deleteRol = async (id) => {
    if(!confirm('¿Eliminar este rol?')) return;
    try {
        const res = await fetch(`${API_URL}/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if(data.success) fetchRoles(); else alert(data.message);
    } catch(e) { console.error(e); }
};

const openCreateModal = () => { isEditing.value = false; Object.assign(form, { id: null, nombre: '', descripcion: '' }); showModal.value = true; };
const openEditModal = (r) => { isEditing.value = true; Object.assign(form, { id: r.rol_codigo, nombre: r.rol_nombre, descripcion: r.rol_descripcion }); showModal.value = true; };

onMounted(() => fetchRoles());
</script>

<style scoped>
/* ESTILOS (Mismo tema que tus otros módulos) */
.container-fluid { padding: 30px; background-color: #f8fafc; min-height: 100vh; font-family: 'Segoe UI', sans-serif; }
.header-actions { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
.header-actions h2 { color: #1e293b; margin: 0; font-weight: 700; }
.subtitle { color: #64748b; margin: 0; font-size: 0.9rem; }

.table-card { background: white; border-radius: 12px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); overflow: hidden; }
.styled-table { width: 100%; border-collapse: collapse; }
.styled-table th { background: #f1f5f9; color: #475569; padding: 16px; font-size: 0.85rem; text-transform: uppercase; font-weight: 600; text-align: left; }
.styled-table td { padding: 16px; border-bottom: 1px solid #e2e8f0; color: #334155; }
.id-tag { color: #64748b; font-weight: 600; font-size: 0.85rem; }
.font-bold { font-weight: 600; color: #0f172a; }
.text-muted { color: #94a3b8; font-size: 0.9rem; }

.btn-main { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; display: flex; gap: 8px; align-items: center; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; }

.action-group { display: flex; gap: 5px; justify-content: center; }
.action-btn { width: 32px; height: 32px; border: none; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; background: transparent; transition: 0.2s; }
.btn-edit:hover { background: #f3e8ff; } 
.btn-delete:hover { background: #fee2e2; }

.modal-backdrop { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-window { background: white; border-radius: 16px; width: 95%; max-width: 500px; display: flex; flex-direction: column; animation: slideUp 0.3s ease-out; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

.modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
.close-icon { background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer; }
.modal-body { padding: 24px; }
.modal-footer { padding: 20px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; background: #f8fafc; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px; }

.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #475569; font-size: 0.85rem; }
.input-field { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; background: white; }
.empty-state { text-align: center; color: #94a3b8; font-style: italic; }
</style>