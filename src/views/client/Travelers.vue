<template>
  <div class="travelers-container">
    
    <div class="header-action">
      <h3>Mis Viajeros</h3>
      <button @click="showCreateModal = true" class="btn-primary">Registrar Viajero</button>
    </div>

    <div v-if="travelers.length > 0" class="travelers-list">
      <div v-for="t in travelers" :key="t.via_codigo" class="traveler-card">
        <div class="card-info">
          <h4>{{ t.via_prim_nombre }} {{ t.via_prim_apellido }}</h4>
          <p class="subtext">
             Edad: <strong>{{ calculateAge(t.via_fecha_nacimiento) }} años</strong> 
             <span class="divider">|</span> 
             Nacimiento: {{ formatDate(t.via_fecha_nacimiento) }}
          </p>
        </div>
        <div class="card-actions">
          <button @click="openDocModal(t)" class="btn-sm">Agreg. Doc</button>
          <button @click="openStatusModal(t)" class="btn-sm">Estado Civil</button>
          <button @click="viewDetails(t)" class="btn-sm btn-outline">Ver Detalle</button>
        </div>
      </div>
    </div>
    <div v-else class="empty-state">
      <p>No tienes viajeros registrados aún.</p>
    </div>

    <div v-if="showCreateModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Nuevo Viajero</h3>
        <form @submit.prevent="createTraveler">
          <div class="form-group"><input v-model="newTraveler.prim_nombre" placeholder="Primer Nombre" required /></div>
          <div class="form-group"><input v-model="newTraveler.seg_nombre" placeholder="Segundo Nombre" /></div>
          <div class="form-group"><input v-model="newTraveler.prim_apellido" placeholder="Primer Apellido" required /></div>
          <div class="form-group"><input v-model="newTraveler.seg_apellido" placeholder="Segundo Apellido" /></div>
          <div class="form-group">
            <label>Fecha Nacimiento</label>
            <input type="date" v-model="newTraveler.fecha_nac" required />
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">Guardar</button>
            <button type="button" @click="showCreateModal = false" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showDocModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Documento para {{ selectedTraveler.via_prim_nombre }}</h3>
        <form @submit.prevent="saveDocument">
          <div class="form-group">
            <label>Tipo</label>
            <select v-model="newDoc.tipo" required>
              <option value="Pasaporte">Pasaporte</option>
              <option value="Visa">Visa</option>
              <option value="Cedula">Cédula</option>
            </select>
          </div>
          <div class="form-group">
            <label>Número</label>
            <input v-model="newDoc.numero" placeholder="Número Documento" required />
          </div>
          <div class="form-row">
            <div class="form-group"><label>Emisión</label><input type="date" v-model="newDoc.fecha_emision" required /></div>
            <div class="form-group"><label>Vencimiento</label><input type="date" v-model="newDoc.fecha_venc" required /></div>
          </div>
          <div class="form-group">
            <label>Nacionalidad</label>
            <select v-model="newDoc.nac_nombre" required>
              <option disabled value="">Seleccione una nacionalidad</option>
              <option v-for="nac in nationalities" :key="nac.nac_codigo" :value="nac.nac_nombre">{{ nac.nac_nombre }}</option>
            </select>
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">Guardar</button>
            <button type="button" @click="showDocModal = false" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showStatusModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Actualizar Estado Civil</h3>
        <form @submit.prevent="saveStatus">
          <div class="form-group">
            <select v-model.number="newStatus.edo_codigo" required>
                <option v-for="st in civilStatuses" :key="st.edo_civ_codigo" :value="st.edo_civ_codigo">{{ st.edo_civ_nombre }}</option>
            </select>
          </div>
          <div class="modal-actions">
            <button type="submit" class="btn-primary">Actualizar</button>
            <button type="button" @click="showStatusModal = false" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showDetailModal" class="modal-overlay">
      <div class="modal-content large">
        <h3>Detalles de {{ selectedTraveler.via_prim_nombre }}</h3>
        
        <div class="detail-section">
            <h4>Documentos</h4>
            <ul v-if="details.documentos && details.documentos.length" class="doc-list">
                <li v-for="d in details.documentos" :key="d.doc_codigo" class="doc-item">
                    <div class="doc-info">
                        <strong>{{ d.doc_tipo }}</strong>: {{ d.doc_numero_documento }} 
                        <br>
                        <small class="text-muted">
                           Emisión: {{ formatDate(d.doc_fecha_emision) }} — Vence: {{ formatDate(d.doc_fecha_vencimiento) }} — {{ d.nac_nombre }}
                        </small>
                    </div>
                    <button @click="removeDocument(d.doc_codigo)" class="btn-danger-sm">Eliminar</button>
                </li>
            </ul>
            <p v-else class="text-muted">No tiene documentos registrados.</p>
        </div>

        <div class="detail-section">
            <h4>Historial Civil</h4>
            <ul v-if="details.historial && details.historial.length">
                <li v-for="h in details.historial" :key="h.via_edo_fecha_inicio">
                    <strong>{{ h.edo_civ_nombre }}</strong>: Desde {{ formatDate(h.via_edo_fecha_inicio) }} 
                    <span v-if="h.via_edo_fecha_fin">hasta {{ formatDate(h.via_edo_fecha_fin) }}</span>
                    <span v-else>(Actual)</span>
                </li>
            </ul>
            <p v-else class="text-muted">Sin historial registrado.</p>
        </div>

        <button @click="showDetailModal = false" class="btn-secondary mt-4">Cerrar</button>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';

const travelers = ref([]);
const civilStatuses = ref([]);
const nationalities = ref([]);
const userSession = JSON.parse(localStorage.getItem('user_session') || '{}');

// Modals State
const showCreateModal = ref(false);
const showDocModal = ref(false);
const showStatusModal = ref(false);
const showDetailModal = ref(false);
const selectedTraveler = ref({});
const details = reactive({ documentos: [], historial: [] });

// Forms Data
const newTraveler = reactive({ prim_nombre: '', seg_nombre: '', prim_apellido: '', seg_apellido: '', fecha_nac: '' });
const newDoc = reactive({ tipo: 'Pasaporte', numero: '', fecha_emision: '', fecha_venc: '', nac_nombre: '' });
const newStatus = reactive({ edo_codigo: 1 });

// UTILIDADES
const formatDate = (dateString) => {
    if(!dateString) return '';
    return new Date(dateString).toLocaleDateString(); // Usa la configuración local
};

// NUEVA FUNCIÓN: Calcular Edad
const calculateAge = (dateString) => {
    if(!dateString) return '--';
    const today = new Date();
    const birthDate = new Date(dateString);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    // Ajuste si aún no ha cumplido años este mes
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
};

// --- API CALLS ---
const fetchNationalities = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/nationalities/list');
        const data = await res.json();
        if(data.success) nationalities.value = data.data;
    } catch(e) { console.error("Error cargando nacionalidades:", e); }
};

const fetchCivilStatuses = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/civil-statuses/list');
        const data = await res.json();
        if(data.success) civilStatuses.value = data.data;
    } catch(e) { console.error(e); }
};

const fetchTravelers = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/list', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) travelers.value = data.data;
    } catch(e) { console.error(e); }
};

const createTraveler = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/create', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ...newTraveler, user_id: userSession.user_id })
        });
        const data = await res.json();
        if(data.success) {
            alert('Viajero creado');
            showCreateModal.value = false;
            fetchTravelers();
            Object.assign(newTraveler, { prim_nombre: '', seg_nombre: '', prim_apellido: '', seg_apellido: '', fecha_nac: '' });
        }
    } catch(e) { console.error(e); }
};

const openDocModal = (t) => { 
    selectedTraveler.value = t; 
    newDoc.numero = ''; newDoc.fecha_emision = ''; newDoc.fecha_venc = ''; newDoc.nac_nombre = ''; 
    showDocModal.value = true; 
};

const saveDocument = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/add-document', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ...newDoc, via_codigo: selectedTraveler.value.via_codigo })
        });
        const data = await res.json();
        if(data.success) { 
            alert('Documento agregado'); 
            showDocModal.value = false; 
        } else {
            alert('Error: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

// NUEVA FUNCIÓN: Eliminar Documento
const removeDocument = async (docId) => {
    if(!confirm("¿Estás seguro de que deseas eliminar este documento?")) return;

    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/delete-document', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ doc_codigo: docId })
        });
        const data = await res.json();
        if(data.success) {
            // Actualizamos la lista de detalles sin cerrar el modal
            viewDetails(selectedTraveler.value); 
        } else {
            alert('Error al eliminar: ' + data.message);
        }
    } catch(e) { console.error(e); }
};

const openStatusModal = (t) => { selectedTraveler.value = t; showStatusModal.value = true; };
const saveStatus = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/update-status', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ...newStatus, via_codigo: selectedTraveler.value.via_codigo })
        });
        if((await res.json()).success) { alert('Estado actualizado'); showStatusModal.value = false; }
    } catch(e) { console.error(e); }
};

const viewDetails = async (t) => {
    selectedTraveler.value = t;
    try {
        const res = await fetch('http://localhost:3000/api/users/travelers/details', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ via_codigo: t.via_codigo })
        });
        const data = await res.json();
        if(data.success) {
            details.documentos = data.documentos;
            details.historial = data.historial;
            showDetailModal.value = true;
        }
    } catch(e) { console.error(e); }
};

onMounted(() => {
    if(userSession.user_id){
        fetchTravelers();
        fetchNationalities();
        fetchCivilStatuses();
    }
});
</script>

<style scoped>
.header-action { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
.travelers-list { display: flex; flex-direction: column; gap: 10px; }
.traveler-card { background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); display: flex; justify-content: space-between; align-items: center; border: 1px solid #eee; }
.card-info h4 { margin: 0 0 5px 0; color: #333; }
.subtext { margin: 0; color: #666; font-size: 0.9rem; }
.divider { margin: 0 8px; color: #ddd; }

.btn-primary { background: #e91e63; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 600; transition: background 0.2s; }
.btn-primary:hover { background: #d81557; }
.btn-secondary { background: #f3f4f6; color: #333; border: 1px solid #ddd; padding: 10px 20px; border-radius: 6px; cursor: pointer; margin-left: 10px; }
.btn-sm { font-size: 0.8rem; padding: 6px 12px; margin-left: 8px; cursor: pointer; border-radius: 4px; border: 1px solid #ddd; background: #f9fafb; transition: all 0.2s;}
.btn-sm:hover { background: #eee; }
.btn-outline { color: #e91e63; border-color: #e91e63; background: white; }
.btn-outline:hover { background: #fff0f5; }

/* Botón Rojo Pequeño para Eliminar */
.btn-danger-sm {
    background-color: #fee2e2;
    color: #b91c1c;
    border: 1px solid #fecaca;
    padding: 4px 8px;
    font-size: 0.75rem;
    border-radius: 4px;
    cursor: pointer;
    margin-left: 10px;
    font-weight: bold;
}
.btn-danger-sm:hover { background-color: #fca5a5; color: #7f1d1d; }

.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; padding: 25px; border-radius: 12px; width: 450px; display: flex; flex-direction: column; gap: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto; }
.modal-content.large { width: 650px; }

.form-group { display: flex; flex-direction: column; margin-bottom: 10px; }
.form-group label { margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; color: #555; }
.form-group input, .form-group select { padding: 10px; border: 1px solid #ddd; border-radius: 6px; font-size: 1rem; }
.form-row { display: flex; gap: 15px; }
.form-row .form-group { flex: 1; }

.modal-actions { margin-top: 10px; display: flex; justify-content: flex-end; }
.empty-state { text-align: center; color: #999; padding: 20px; font-style: italic; }
.text-muted { color: #666; font-size: 0.85rem; }

/* Estilos para la lista de detalles */
.doc-list { list-style: none; padding: 0; }
.doc-item { padding: 10px 0; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
.doc-info { flex: 1; }
</style>