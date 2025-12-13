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
            <button class="btn-sm">Editar</button>
            <button class="btn-danger-sm">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Registrar Nuevo Proveedor</h3>
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
                <input type="password" v-model="form.usu_pass" required />
            </div>
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">Registrar</button>
            <button type="button" @click="showModal = false" class="btn-secondary">Cancelar</button>
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
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

const form = reactive({
    pro_nombre: '', 
    prov_fecha_creacion: '', // Variable cambiada a fecha
    pro_tipo: 'Aerolinea', 
    fk_lugar: '',
    usu_nombre: '', usu_email: '', usu_pass: ''
});
const todayDate = new Date().toISOString().split('T')[0];
const formatDate = (dateString) => {
    if(!dateString) return '';
    return new Date(dateString).toLocaleDateString();
};

// --- API ---
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

const saveProvider = async () => {
    try {
        const payload = { ...form, admin_id: userSession.user_id };
        const res = await fetch('http://localhost:3000/api/users/providers/create', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        if(data.success) {
            alert('Proveedor creado');
            showModal.value = false;
            fetchProviders();
            // Limpiar form
            Object.assign(form, { pro_nombre: '', prov_fecha_creacion: '', pro_tipo: 'Aereolinea', fk_lugar: '', usu_nombre: '', usu_email: '', usu_pass: '' });
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

const openCreateModal = () => {
    fetchLocations();
    showModal.value = true;
};

onMounted(() => {
    fetchProviders();
});
</script>

<style scoped>
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; }
.badge { background: #e0f2fe; color: #0284c7; padding: 4px 8px; border-radius: 12px; font-size: 0.8rem; font-weight: 600; }
.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
.btn-sm { padding: 5px 10px; font-size: 0.8rem; margin-right: 5px; cursor: pointer; }
.btn-danger-sm { padding: 5px 10px; font-size: 0.8rem; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; }

/* Modal Styles Reuse */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; }
.modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-height: 90vh; overflow-y: auto; }
.form-section { margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px solid #eee; }
.form-section h4 { margin-bottom: 10px; color: #3b82f6; }
.form-group { margin-bottom: 10px; }
.form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; }
.form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
</style>