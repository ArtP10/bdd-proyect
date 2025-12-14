<template>
  <div class="container">
    <div class="header-actions">
      <h2>📦 Gestión de Paquetes</h2>
      <button @click="openCreateModal" class="btn-main">
        <span>+</span> Crear Paquete Base
      </button>
    </div>

    <div class="table-card">
      <table class="styled-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Nombre</th>
            <th>Costo Total</th>
            <th>Millas</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in packages" :key="p.paq_tur_codigo">
            <td><span class="id-tag">#{{ p.paq_tur_codigo }}</span></td>
            <td class="font-bold">{{ p.paq_tur_nombre }}</td>
            <td>${{ formatCurrency(p.paq_tur_monto_total) }}</td>
            <td><span class="miles-tag">{{ p.paq_tur_costo_en_millas }} pts</span></td>
            <td>
              <div class="action-group">
                <button class="action-btn btn-view" @click="openDetailsModal(p.paq_tur_codigo)" title="Ver Detalle">👁️</button>
                <button class="action-btn btn-config" @click="openConfigModal(p)" title="Configurar Contenido">⚙️</button>
                <button class="action-btn btn-edit" @click="openEditModal(p)" title="Editar">✏️</button>
                <button class="action-btn btn-delete" @click="deletePackage(p.paq_tur_codigo)" title="Eliminar">🗑️</button>
              </div>
            </td>
          </tr>
          <tr v-if="packages.length === 0">
              <td colspan="5" class="empty-text">No hay paquetes registrados aún.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showModal" class="modal-backdrop">
      <div class="modal-window">
        <div class="modal-header">
            <h3>{{ isEditing ? '✏️ Editar Paquete' : '✨ Nuevo Paquete' }}</h3>
            <button class="close-icon" @click="showModal=false">✕</button>
        </div>
        <form @submit.prevent="savePackage">
            <div class="modal-body">
                <div class="form-group">
                    <label>Nombre del Paquete</label>
                    <input v-model="form.nombre" required placeholder="Ej: Viaje a Canaima" class="input-field">
                </div>
                <div class="row-inputs">
                    <div class="form-group"><label>Costo Total ($)</label><input type="number" step="0.01" v-model="form.monto_total" required class="input-field"></div>
                    <div class="form-group"><label>Subtotal ($)</label><input type="number" step="0.01" v-model="form.monto_subtotal" required class="input-field"></div>
                </div>
                <div class="form-group"><label>Costo en Millas</label><input type="number" v-model="form.costo_millas" required class="input-field"></div>
            </div>
            <div class="modal-footer">
                <button type="button" @click="showModal=false" class="btn-secondary">Cancelar</button>
                <button type="submit" class="btn-main">{{ isEditing ? 'Actualizar' : 'Guardar' }}</button>
            </div>
        </form>
      </div>
    </div>

    <div v-if="showConfigModal" class="modal-backdrop">
      <div class="modal-window large">
        <div class="modal-header">
            <h3>⚙️ Configurar: {{ selectedPackage?.paq_tur_nombre }}</h3>
            <button class="close-icon" @click="showConfigModal=false">✕</button>
        </div>

        <div class="tabs-header">
            <button :class="{ active: activeTab === 'reglas' }" @click="activeTab = 'reglas'">📜 Reglas</button>
            <button :class="{ active: activeTab === 'servicios' }" @click="activeTab = 'servicios'">🎫 Servicios</button>
            <button :class="{ active: activeTab === 'habitacion' }" @click="activeTab = 'habitacion'">🏨 Habitación</button>
            <button :class="{ active: activeTab === 'restaurante' }" @click="activeTab = 'restaurante'">🍽️ Restaurante</button>
            <button :class="{ active: activeTab === 'traslados' }" @click="activeTab = 'traslados'">✈️ Traslados</button>
        </div>

        <div class="modal-body tab-body">
            <div v-if="activeTab === 'reglas'">
                <h4>Asignar Regla</h4>
                <div class="assign-box">
                    <select v-model="selectedRuleId" class="input-field"><option v-for="r in listRules" :value="r.reg_paq_codigo">{{ r.reg_paq_atributo }} {{ r.reg_paq_operador }} {{ r.reg_paq_valor }}</option></select>
                    <button class="btn-main small" @click="assignItem('regla')">Asignar</button>
                </div>
            </div>
            <div v-if="activeTab === 'servicios'">
                <h4>Agregar Servicio</h4>
                <div class="assign-box">
                    <select v-model="selectedServiceId" class="input-field"><option v-for="s in listGenericServices" :value="s.id">{{ s.nombre }}</option></select>
                    <input type="number" v-model="serviceQty" class="input-field qty" min="1">
                    <button class="btn-main small" @click="assignItem('servicio')">Agregar</button>
                </div>
            </div>
            <div v-if="activeTab === 'habitacion'">
                <h4>Reservar Habitación</h4>
                <div class="form-group">
                    <select v-model="roomForm.id_habitacion" class="input-field"><option v-for="h in listRooms" :value="h.id">{{ h.info_hotel }} | {{ h.info_habitacion }} | ${{ h.costo }}</option></select>
                </div>
                <div class="row-inputs">
                    <div class="form-group"><label>Entrada</label><input type="datetime-local" v-model="roomForm.fecha_inicio" class="input-field"></div>
                    <div class="form-group"><label>Salida</label><input type="datetime-local" v-model="roomForm.fecha_fin" class="input-field"></div>
                </div>
                <button class="btn-main full" @click="saveRoomReservation">Reservar</button>
            </div>
            <div v-if="activeTab === 'restaurante'">
                <h4>Reservar Mesa</h4>
                <div class="form-group">
                    <select v-model="restForm.id_restaurante" class="input-field"><option v-for="r in listRestaurants" :value="r.id">{{ r.nombre }}</option></select>
                </div>
                <div class="row-inputs">
                    <div class="form-group"><label>Fecha</label><input type="datetime-local" v-model="restForm.fecha" class="input-field"></div>
                    <div class="form-group"><label>Mesa #</label><input type="number" v-model="restForm.num_mesa" class="input-field"></div>
                    <div class="form-group"><label>Pers.</label><input type="number" v-model="restForm.tamano_mesa" class="input-field"></div>
                </div>
                <button class="btn-main full" @click="saveRestReservation">Reservar</button>
            </div>
            <div v-if="activeTab === 'traslados'">
                <h4>Agregar Traslado</h4>
                <div class="assign-box">
                    <select v-model="selectedTransferId" class="input-field"><option v-for="t in listTransfers" :value="t.id">{{ t.descripcion }} - ${{ t.costo }}</option></select>
                    <button class="btn-main small" @click="assignItem('traslado')">Agregar</button>
                </div>
            </div>
        </div>
      </div>
    </div>

    <div v-if="showDetailModal" class="modal-backdrop">
      <div class="modal-window">
        <div class="modal-header">
           <h3>🔍 Detalle del Paquete</h3>
           <button class="close-icon" @click="showDetailModal=false">✕</button>
        </div>
        
        <div v-if="detailData" class="modal-body detail-view">
             <div class="detail-summary">
                 <h4 class="detail-title">{{ detailData.info.paq_tur_nombre }}</h4>
                 <div class="price-badge">Total: ${{ formatCurrency(detailData.info.paq_tur_monto_total) }}</div>
             </div>
             
             <div class="detail-section" v-if="detailData.alojamientos && detailData.alojamientos.length > 0">
                <h5>🏨 Alojamiento</h5>
                <ul class="detail-list">
                    <li v-for="(a, i) in detailData.alojamientos" :key="'alo'+i" class="item-card success">
                        <div class="item-header"><strong>{{ a.nombre_hotel }}</strong></div>
                        <div class="item-sub">Habitación: {{ a.habitacion }}</div>
                        <div class="item-dates">📅 {{ a.entrada }} ➝ {{ a.salida }}</div>
                    </li>
                </ul>
             </div>

             <div class="detail-section" v-if="detailData.restaurantes && detailData.restaurantes.length > 0">
                <h5>🍽️ Restaurantes</h5>
                <ul class="detail-list">
                    <li v-for="(r, i) in detailData.restaurantes" :key="'res'+i" class="item-card warning">
                        <div class="item-header"><strong>{{ r.nombre_restaurante }}</strong></div>
                        <div class="item-sub">Mesa #{{ r.mesa }} ({{ r.personas }} pers.)</div>
                        <div class="item-dates">📅 {{ r.fecha }}</div>
                    </li>
                </ul>
             </div>

             <div class="detail-section" v-if="detailData.servicios_genericos && detailData.servicios_genericos.length > 0">
                <h5>🎫 Otros Servicios</h5>
                <ul class="detail-list">
                    <li v-for="(s, i) in detailData.servicios_genericos" :key="'ser'+i" class="item-simple">
                        <span class="badge info">{{ s.tipo }}</span> {{ s.cantidad }}x {{ s.nombre }}
                    </li>
                </ul>
             </div>

             <div class="detail-section" v-if="detailData.traslados && detailData.traslados.length > 0">
                <h5>✈️ Traslados</h5>
                <ul class="detail-list">
                    <li v-for="(t, i) in detailData.traslados" :key="'tras'+i" class="item-simple">
                        <span class="route-arrow">➔</span> {{ t.origen }} a {{ t.destino }} <small>({{ t.tipo }})</small>
                    </li>
                </ul>
             </div>
             
             <div class="detail-section" v-if="detailData.reglas && detailData.reglas.length > 0">
                 <h5>⚠️ Condiciones</h5>
                 <div class="tags-container">
                     <span v-for="(r, i) in detailData.reglas" :key="i" class="rule-tag">{{ r.atributo }} {{ r.operador }} {{ r.valor }}</span>
                 </div>
             </div>

             <div v-if="!detailData.alojamientos?.length && !detailData.restaurantes?.length && !detailData.servicios_genericos?.length && !detailData.traslados?.length && !detailData.reglas?.length" class="empty-state-box">
                Este paquete no tiene contenido asignado todavía.
             </div>
        </div>
        <div v-else class="modal-body loading-text">Cargando detalles...</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';

const packages = ref([]);
const showModal = ref(false);
const showConfigModal = ref(false);
const showDetailModal = ref(false);
const isEditing = ref(false);
const activeTab = ref('reglas');
const selectedPackage = ref(null);
const detailData = ref(null);

const listRules = ref([]);
const listGenericServices = ref([]);
const listRooms = ref([]);
const listRestaurants = ref([]);
const listTransfers = ref([]);

const selectedRuleId = ref('');
const selectedServiceId = ref('');
const serviceQty = ref(1);
const selectedTransferId = ref('');

const form = reactive({ id: null, nombre: '', monto_total: 0, monto_subtotal: 0, costo_millas: 0 });
const roomForm = reactive({ id_habitacion: '', fecha_inicio: '', fecha_fin: '' });
const restForm = reactive({ id_restaurante: '', fecha: '', num_mesa: '', tamano_mesa: '' });

const formatCurrency = (val) => Number(val).toFixed(2);

const fetchPackages = async () => {
    try {
        const res = await fetch('http://localhost:3000/api/paquetes');
        const data = await res.json();
        if(data.success) packages.value = data.data;
    } catch(e) { console.error(e); }
};

const loadCatalogs = async () => {
    try {
        const [r1, r2, r3, r4, r5] = await Promise.all([
            fetch('http://localhost:3000/api/reglas').then(r => r.json()),
            fetch('http://localhost:3000/api/opciones/servicios').then(r => r.json()),
            fetch('http://localhost:3000/api/opciones/habitaciones').then(r => r.json()),
            fetch('http://localhost:3000/api/opciones/restaurantes').then(r => r.json()),
            fetch('http://localhost:3000/api/traslados-disponibles').then(r => r.json())
        ]);
        if(r1.success) listRules.value = r1.data;
        if(r2.success) listGenericServices.value = r2.data;
        if(r3.success) listRooms.value = r3.data;
        if(r4.success) listRestaurants.value = r4.data;
        if(r5.success) listTransfers.value = r5.data;
    } catch(e) { console.error(e); }
};

const savePackage = async () => {
    try {
        const url = isEditing.value ? `http://localhost:3000/api/paquetes/${form.id}` : 'http://localhost:3000/api/paquetes';
        const method = isEditing.value ? 'PUT' : 'POST';
        const res = await fetch(url, { method, headers: {'Content-Type': 'application/json'}, body: JSON.stringify(form) });
        const data = await res.json();
        if(data.success) { showModal.value=false; fetchPackages(); }
    } catch(e) { console.error(e); }
};

const deletePackage = async (id) => {
    if(!confirm('¿Eliminar paquete?')) return;
    try {
        const res = await fetch(`http://localhost:3000/api/paquetes/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if(data.success) { alert('Eliminado'); fetchPackages(); }
    } catch(e) { console.error(e); }
};

const assignItem = async (type) => {
    let url = '', payload = {};
    const pkgId = selectedPackage.value.paq_tur_codigo;
    if (type === 'regla') { url = 'http://localhost:3000/api/asignar-regla'; payload = { fk_paq_tur_codigo: pkgId, fk_reg_paq_codigo: selectedRuleId.value }; } 
    else if (type === 'servicio') { url = 'http://localhost:3000/api/asignar/servicio-generico'; payload = { id_paquete: pkgId, id_servicio: selectedServiceId.value, cantidad: serviceQty.value }; }
    else if (type === 'traslado') { url = 'http://localhost:3000/api/asignar-traslado'; payload = { id_paquete: pkgId, id_traslado: selectedTransferId.value }; }

    try {
        const res = await fetch(url, { method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(payload) });
        const data = await res.json();
        if(data.success) alert("Agregado"); else alert(data.message);
    } catch(e) { console.error(e); }
};

const saveRoomReservation = async () => {
    if(!roomForm.id_habitacion || !roomForm.fecha_inicio) return alert("Faltan datos");
    const room = listRooms.value.find(r => r.id === roomForm.id_habitacion);
    try {
        const res = await fetch('http://localhost:3000/api/reservar/habitacion', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                id_paquete: selectedPackage.value.paq_tur_codigo,
                id_habitacion: roomForm.id_habitacion,
                fecha_inicio: roomForm.fecha_inicio,
                fecha_fin: roomForm.fecha_fin,
                costo: room ? room.costo : 0
            })
        });
        const data = await res.json();
        if(data.success) alert("Reservado"); else alert(data.message);
    } catch(e) { console.error(e); }
};

const saveRestReservation = async () => {
    if(!restForm.id_restaurante || !restForm.fecha) return alert("Faltan datos");
    try {
        const res = await fetch('http://localhost:3000/api/reservar/restaurante', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                id_paquete: selectedPackage.value.paq_tur_codigo,
                id_restaurante: restForm.id_restaurante,
                fecha: restForm.fecha,
                num_mesa: restForm.num_mesa,
                tamano_mesa: restForm.tamano_mesa
            })
        });
        const data = await res.json();
        if(data.success) alert("Reservado"); else alert(data.message);
    } catch(e) { console.error(e); }
};

const openDetailsModal = async (id) => {
    detailData.value = null; 
    showDetailModal.value = true;
    try {
        const res = await fetch(`http://localhost:3000/api/paquetes/${id}/detalles`);
        const data = await res.json();
        if(data.success) detailData.value = data.data;
    } catch(e) { console.error(e); }
};

const openCreateModal = () => { isEditing.value=false; Object.assign(form, {nombre:'', monto_total:0}); showModal.value=true; };
const openEditModal = (p) => { isEditing.value=true; Object.assign(form, {id:p.paq_tur_codigo, nombre:p.paq_tur_nombre, monto_total:p.paq_tur_monto_total}); showModal.value=true; };
const openConfigModal = (p) => { selectedPackage.value=p; loadCatalogs(); showConfigModal.value=true; };
onMounted(() => fetchPackages());
</script>

<style scoped>
/* ESTILOS (Pegar aquí los estilos de tu archivo anterior o los que te pasé antes) */
.container { padding: 30px; background-color: #f1f5f9; min-height: 100vh; font-family: 'Segoe UI', sans-serif; }
.header-actions { display: flex; justify-content: space-between; margin-bottom: 25px; }
.table-card { background: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); overflow: hidden; }
.styled-table { width: 100%; border-collapse: collapse; }
.styled-table th { background: #f8fafc; color: #64748b; padding: 16px; text-align: left; }
.styled-table td { padding: 16px; border-bottom: 1px solid #e2e8f0; }
.btn-main { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
.modal-backdrop { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(3px); display: flex; justify-content: center; align-items: center; z-index: 999; }
.modal-window { background: white; border-radius: 16px; width: 500px; max-height: 90vh; display: flex; flex-direction: column; }
.modal-window.large { width: 800px; }
.modal-header { padding: 20px; border-bottom: 1px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; }
.modal-body { padding: 25px; overflow-y: auto; }
.tabs-header { display: flex; padding: 0 25px; border-bottom: 1px solid #e2e8f0; gap: 20px; }
.tabs-header button { background: none; border: none; padding: 15px 0; color: #64748b; font-weight: 600; cursor: pointer; border-bottom: 2px solid transparent; }
.tabs-header button.active { color: #3b82f6; border-bottom-color: #3b82f6; }
.input-field { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; }
/* Tarjetas de Detalle */
.item-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 12px; margin-bottom: 10px; }
.item-card.success { border-left: 4px solid #22c55e; background: #f0fdf4; }
.item-card.warning { border-left: 4px solid #f59e0b; background: #fffbeb; }
.item-header strong { font-size: 1rem; color: #334155; }
.item-sub, .item-dates { font-size: 0.85rem; color: #64748b; }
.detail-list { list-style: none; padding: 0; }
.price-badge { background: #dcfce7; color: #166534; font-weight: 800; padding: 5px 12px; border-radius: 20px; }
.empty-text, .empty-state-box { color: #94a3b8; text-align: center; font-style: italic; }
.action-btn { width: 35px; height: 35px; border: none; cursor: pointer; margin-right: 5px; background: #eee; border-radius: 5px; }
</style>