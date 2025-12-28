<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">Crear Proveedor</button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Tipo</th>
          <th>Lugar</th>
          <th>Fundación</th> <th>Antigüedad</th> <th>Usuario Admin</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="p in providers" :key="p.prov_codigo">
          <td>{{ p.prov_nombre }}</td>
          <td><span class="badge">{{ p.prov_tipo }}</span></td>
          <td>{{ p.lug_nombre }}</td>
          <td>{{ formatDate(p.prov_fecha_creacion) }}</td>
          <td>{{ p.anos_antiguedad }} años</td>
          <td>{{ p.usu_nombre_usuario }}</td>
          <td>
            <button class="btn-sm" @click="openEditModal(p)">Editar</button>
            <button class="btn-danger-sm" @click="deleteProvider(p.prov_codigo)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Editar Proveedor' : 'Registrar Nuevo Proveedor' }}</h3>
        <form @submit.prevent="saveProvider">
          
          <div class="form-section">
            <h4>Datos de la Empresa</h4>
            <div class="form-group">
                <label>Nombre Proveedor</label>
                <input v-model="form.pro_nombre" required />
            </div>
            
            <div class="form-group">
                <label>Fecha de Creación / Fundación</label>
                <input type="date" v-model="form.prov_fecha_creacion" required :max="todayDate" />
            </div>

            <div class="form-group">
                <label>Tipo</label>
                <select v-model="form.pro_tipo" required>
                    <option value="Aerolinea">Aerolinea</option>
                    <option value="Terrestre">Terrestre</option>
                    <option value="Maritimo">Maritimo</option>
                    <option value="Otros">Otros</option>
                </select>
            </div>
            <div class="form-group">
                <label>Lugar de Operación</label>
                <select v-model="form.fk_lugar" required>
                    <option v-for="l in locations" :key="l.lug_codigo" :value="l.lug_codigo">
                        {{ l.lug_nombre }}
                    </option>
                </select>
            </div>
          </div>
            
           <div class="form-section">
            <h4>Cuenta de Acceso</h4>
            <div class="form-group">
                <label>Usuario</label>
                <input v-model="form.usu_nombre" required />
            </div>
            <div class="form-group">
                <label>Email</label>
                <input type="email" v-model="form.usu_email" required />
            </div>
            <div class="form-group">
                <label>Contraseña</label>
                <input type="password" v-model="form.usu_pass" :required="!isEditing" :placeholder="isEditing ? 'Dejar vacío para no cambiar' : ''" :disabled="isEditing"/>
                <small v-if="isEditing" style="color:gray; font-size:0.8em">La edición de contraseña no está permitida aquí.</small>
            </div>
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

const providers = ref([]);
const locations = ref([]);
const showModal = ref(false);
const isEditing = ref(false); // Estado para saber si editamos
const currentEditId = ref(null); // ID del proveedor que se edita

const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

const form = reactive({
    pro_nombre: '', 
    prov_fecha_creacion: '',
    pro_tipo: 'Aerolinea', 
    fk_lugar: '',
    usu_nombre: '', usu_email: '', usu_pass: ''
});

const todayDate = new Date().toISOString().split('T')[0];

const formatDate = (dateString) => {
    if(!dateString) return '';
    return new Date(dateString).toLocaleDateString();
};

// --- API FETCH ---
const fetchLocations = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/locations/list');
        const data = await res.json();
        if(data.success) locations.value = data.data;
    } catch(e) { console.error(e); }
};

const fetchProviders = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/providers/list');
        const data = await res.json();
        if(data.success) providers.value = data.data;
    } catch(e) { console.error(e); }
};

// --- ACCIONES CRUD ---

// 1. GUARDAR (CREAR O EDITAR)
const saveProvider = async () => {
    try {
        // Determinamos URL y Método según el modo
        const url = isEditing.value 
            ? 'http://localhost:3000/api/users/providers/update' 
            : 'http://localhost:3000/api/users/providers/create';
        
        const method = isEditing.value ? 'PUT' : 'POST';
        
        const payload = { 
            ...form, 
            admin_id: userSession.user_id,
            // Si estamos editando, agregamos el ID del proveedor
            prov_codigo: isEditing.value ? currentEditId.value : undefined
        };

        const res = await fetch(url, {
            method: method,
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert(isEditing.value ? 'Proveedor actualizado' : 'Proveedor creado');
            closeModal();
            fetchProviders();
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// 2. ELIMINAR
const deleteProvider = async (id) => {
    if(!confirm('¿Estás seguro de eliminar este proveedor? Se eliminará también su usuario asociado.')) return;

    try {
        const res = await fetch('http://localhost:3000/api/users/providers/delete', {
            method: 'DELETE',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ 
                admin_id: userSession.user_id, 
                prov_codigo: id 
            })
        });
        const data = await res.json();
        
        if(data.success) {
            alert('Proveedor eliminado');
            fetchProviders();
        } else {
            alert('Error al eliminar: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// --- MANEJO DEL MODAL ---

const openCreateModal = () => {
    isEditing.value = false;
    currentEditId.value = null;
    resetForm();
    fetchLocations();
    showModal.value = true;
};

const openEditModal = (provider) => {
    isEditing.value = true;
    currentEditId.value = provider.prov_codigo;
    
    // Asegurarnos de tener los lugares cargados
    if (locations.value.length === 0) {
        fetchLocations(); 
    }
    
    // Mapeo de datos: De la fila (provider) al Formulario (form)
    Object.assign(form, {
        pro_nombre: provider.prov_nombre,
        // Convertir formato ISO a YYYY-MM-DD para el input date
        prov_fecha_creacion: provider.prov_fecha_creacion ? provider.prov_fecha_creacion.split('T')[0] : '',
        pro_tipo: provider.prov_tipo,
        fk_lugar: provider.fk_lugar,
        
        // --- AQUÍ ESTÁ LA CORRECCIÓN ---
        // Asignamos los datos del usuario que vienen del JOIN en el backend
        usu_nombre: provider.usu_nombre_usuario, 
        usu_email: provider.usu_email,
        
        // La contraseña se deja vacía al editar para indicar "no cambiar"
        usu_pass: '' 
    });
    
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
    resetForm();
};

const resetForm = () => {
    Object.assign(form, { pro_nombre: '', prov_fecha_creacion: '', pro_tipo: 'Aerolinea', fk_lugar: '', usu_nombre: '', usu_email: '', usu_pass: '' });
};

onMounted(() => {
    fetchProviders();
});
</script>

<style scoped>
/* (Tus estilos se mantienen igual) */
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; }
.badge { background: #e0f2fe; color: #0284c7; padding: 4px 8px; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
.btn-sm { padding: 5px 10px; font-size: 0.8rem; margin-right: 5px; cursor: pointer; background: #e2e8f0; border: none; border-radius: 4px; }
.btn-danger-sm { padding: 5px 10px; font-size: 0.8rem; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; border-radius: 4px; }
.btn-secondary { background: #94a3b8; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }

.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; }
.modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-height: 90vh; overflow-y: auto; }
.form-section { margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
.form-section h4 { margin-bottom: 10px; color: #3b82f6; }
.form-group { margin-bottom: 10px; }
.form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; }
.form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
</style>