<template>
  <div class="container-fluid">
    <div class="header-actions">
      <div>
        <h2>🏷️ Gestión de Promociones</h2>
        <p class="subtitle">Crea descuentos y asígnalos a hoteles, restaurantes o servicios</p>
      </div>
      <button @click="openCreateModal" class="btn-main">
        <span>+</span> Nueva Promoción
      </button>
    </div>

    <div class="table-card">
      <table class="styled-table">
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Descuento</th>
            <th>Vencimiento</th>
            <th class="text-center">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in promociones" :key="p.prom_codigo">
            <td class="font-bold">{{ p.prom_nombre }}</td>
            <td class="text-muted">{{ p.prom_descripcion }}</td>
            <td><span class="discount-tag">{{ p.prom_descuento }}% OFF</span></td>
            <td>{{ formatDate(p.prom_fecha_hora_vencimiento) }}</td>
            <td class="text-center">
              <div class="action-group">
                <button class="action-btn btn-view" @click="openDetailModal(p.prom_codigo)" title="Ver Asignaciones">
                  👁️
                </button>
                
                <button class="action-btn btn-config" @click="openBuilderModal(p)" title="Asignar a Elementos">
                  ⚙️
                </button>
                
                <button class="action-btn btn-edit" @click="openEditModal(p)" title="Editar">
                  ✏️
                </button>
                
                <button class="action-btn btn-delete" @click="eliminarPromocion(p.prom_codigo)" title="Eliminar">
                  🗑️
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="promociones.length === 0">
              <td colspan="5" class="empty-text">No hay promociones registradas.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="showFormModal" class="modal-backdrop" @click.self="showFormModal=false">
      <div class="modal-window slide-in">
        <div class="modal-header">
            <h3>{{ isEditing ? '✏️ Editar' : '✨ Nueva' }} Promoción</h3>
            <button class="close-icon" @click="showFormModal=false">✕</button>
        </div>
        <form @submit.prevent="savePromocion">
          <div class="modal-body">
            <div class="form-group"><label>Nombre</label><input v-model="form.nombre" required class="input-field" /></div>
            <div class="form-group"><label>Descripción</label><input v-model="form.descripcion" required class="input-field" /></div>
            <div class="row-inputs">
                <div class="form-group"><label>Descuento (%)</label><input type="number" v-model="form.descuento" required class="input-field" /></div>
                <div class="form-group"><label>Vence</label><input type="datetime-local" v-model="form.fecha_vencimiento" required class="input-field" /></div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" @click="showFormModal=false" class="btn-secondary">Cancelar</button>
            <button type="submit" class="btn-main">{{ isEditing ? 'Guardar' : 'Crear' }}</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showBuilderModal" class="modal-backdrop" @click.self="showBuilderModal=false">
      <div class="modal-window large slide-in">
        <div class="modal-header config-header">
            <div>
                <small>Asignando promoción:</small>
                <h3>{{ selectedPromo?.prom_nombre }} <span class="discount-badge">{{ selectedPromo?.prom_descuento }}%</span></h3>
            </div>
            <button class="close-icon" @click="showBuilderModal=false">✕</button>
        </div>
        <div class="modal-body builder-body">
            <div class="filter-box">
                <div class="row-inputs centered-row">
                    <div class="form-group flex-grow">
                        <label>¿Qué deseas buscar?</label>
                        <select v-model="filters.tipo" class="input-field" @change="resetResults">
                            <option value="" disabled>-- Seleccione Tipo --</option>
                            <option value="hotel">🏨 Hoteles (Ver Habitaciones)</option>
                            <option value="restaurante">🍽️ Restaurantes</option>
                            <option value="servicio">🎟️ Servicios / Tours</option>
                            <option value="paquete">📦 Paquetes</option>
                            <option value="traslado">✈️ Traslados</option>
                        </select>
                    </div>
                    <div class="form-group btn-container">
                        <button @click="executeSearch" :disabled="!filters.tipo || builderLoading" class="btn-main">
                            {{ builderLoading ? '...' : 'Buscar' }}
                        </button>
                    </div>
                </div>
            </div>
            <div class="results-area">
                <div v-if="viewingRoomsMode" class="back-bar">
                    <button @click="backToHotels" class="btn-secondary small">← Volver a Hoteles</button>
                    <span>Viendo habitaciones de: <strong>{{ selectedHotelName }}</strong></span>
                </div>
                <div v-if="builderResults.length > 0">
                    <table class="styled-table">
                        <thead>
                            <tr><th>Elemento</th><th>Info</th><th>Precio</th><th class="text-center">Asignar</th></tr>
                        </thead>
                        <tbody>
                            <tr v-for="item in builderResults" :key="item.elemento_id">
                                <td><strong>{{ item.nombre_elemento }}</strong></td>
                                <td class="text-muted small-text">{{ item.info_basica }}</td>
                                <td class="amount-text">${{ item.costo }}</td>
                                <td class="text-center">
                                    <button v-if="filters.tipo === 'hotel' && !viewingRoomsMode" @click="loadHotelRooms(item)" class="btn-view-rooms">Ver Habitaciones</button>
                                    <button v-else @click="toggleAssignment(item)" :class="item.asignado ? 'btn-danger-sm' : 'btn-success-sm'" :disabled="item.loading">{{ item.loading ? '...' : (item.asignado ? '❌ Quitar' : '✅ Aplicar') }}</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div v-else-if="searchAttempted" class="empty-results"><p>No se encontraron resultados.</p></div>
                <div v-else class="empty-results initial"><p>Selecciona un tipo para comenzar.</p></div>
            </div>
        </div>
      </div>
    </div>

    <div v-if="showDetailModal" class="modal-backdrop" @click.self="showDetailModal=false">
        <div class="modal-window slide-in">
            <div class="modal-header">
                <h3>Resumen de Asignaciones</h3>
                <button class="close-icon" @click="showDetailModal=false">✕</button>
            </div>
            <div v-if="detailData" class="modal-body detail-view">
                <div class="detail-header">
                    <h4>{{ detailData.info.prom_nombre }}</h4>
                    <span class="discount-badge">{{ detailData.info.prom_descuento }}% OFF</span>
                </div>
                <div class="detail-block" v-if="detailData.restaurantes?.length"><h5>🍽️ Restaurantes</h5><div v-for="r in detailData.restaurantes" class="detail-item"><strong>{{ r.res_nombre }}</strong></div></div>
                <div class="detail-block" v-if="detailData.habitaciones?.length"><h5>🏨 Habitaciones</h5><div v-for="h in detailData.habitaciones" class="detail-item"><strong>{{ h.hot_nombre }}</strong>: {{ h.hab_descripcion }}</div></div>
                <div class="detail-block" v-if="detailData.servicios?.length"><h5>🎟️ Servicios</h5><div v-for="s in detailData.servicios" class="detail-item">{{ s.ser_nombre }}</div></div>
                <div class="detail-block" v-if="detailData.paquetes?.length"><h5>📦 Paquetes</h5><div v-for="p in detailData.paquetes" class="detail-item">{{ p.paq_tur_nombre }}</div></div>
                <div class="detail-block" v-if="detailData.traslados?.length"><h5>✈️ Traslados</h5><div v-for="t in detailData.traslados" class="detail-item">{{ t.origen }} ➝ {{ t.destino }}</div></div>
                <div v-if="isEmptyDetail" class="empty-results"><p>Sin asignaciones.</p></div>
            </div>
            <div v-else class="modal-body loading-text">Cargando...</div>
        </div>
    </div>
  </div>
</template>

<script setup>
// Asegúrate de incluir todo el script y estilos que te pasé en la respuesta anterior
import { ref, reactive, computed, onMounted } from 'vue';

const API_BASE = 'http://localhost:3000/api/promociones';

// ESTADOS
const promociones = ref([]);
const showFormModal = ref(false);
const showBuilderModal = ref(false);
const showDetailModal = ref(false);
const isEditing = ref(false);
const detailData = ref(null);

// BUILDER ESTADOS
const selectedPromo = ref(null);
const builderResults = ref([]);
const builderLoading = ref(false);
const searchAttempted = ref(false);
const filters = reactive({ tipo: '' });

// LOGICA HOTELES
const viewingRoomsMode = ref(false);
const selectedHotelName = ref('');
const cachedHotels = ref([]);

const form = reactive({ codigo: null, nombre: '', descripcion: '', descuento: 0, fecha_vencimiento: '' });

// HELPERS
const minDateTime = computed(() => {
    const now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    return now.toISOString().slice(0, 16);
});

const formatDate = (d) => d ? new Date(d).toLocaleDateString('es-VE') : '';

const isEmptyDetail = computed(() => {
    if(!detailData.value) return true;
    return !detailData.value.paquetes?.length && 
           !detailData.value.servicios?.length && 
           !detailData.value.habitaciones?.length && 
           !detailData.value.traslados?.length &&
           !detailData.value.restaurantes?.length;
});

// CRUD API
const fetchPromociones = async () => {
    try { const res = await fetch(API_BASE); const data = await res.json(); if(data.success) promociones.value = data.data; } catch(e) { console.error(e); }
};

const savePromocion = async () => {
    try {
        const url = isEditing.value ? `${API_BASE}/${form.codigo}` : API_BASE;
        const method = isEditing.value ? 'PUT' : 'POST';
        const res = await fetch(url, { method, headers: {'Content-Type': 'application/json'}, body: JSON.stringify(form) });
        const data = await res.json();
        if(data.success) { showFormModal.value=false; fetchPromociones(); }
        else alert(data.message);
    } catch(e) { console.error(e); }
};

const eliminarPromocion = async (id) => {
    if(!confirm('¿Eliminar esta promoción permanentemente?')) return;
    try {
        const res = await fetch(`${API_BASE}/${id}`, { method: 'DELETE' });
        const data = await res.json();
        if(data.success) fetchPromociones();
    } catch(e) { console.error(e); }
};

// BUILDER LOGIC
const openBuilderModal = (promo) => {
    selectedPromo.value = promo;
    resetResults();
    showBuilderModal.value = true;
};

const resetResults = () => {
    builderResults.value = [];
    searchAttempted.value = false;
    viewingRoomsMode.value = false;
};

const executeSearch = async () => {
    builderLoading.value = true; searchAttempted.value = true; viewingRoomsMode.value = false;
    try {
        const res = await fetch(`${API_BASE}/builder/${selectedPromo.value.prom_codigo}/elementos?tipo=${filters.tipo}`);
        const data = await res.json();
        if(data.success) {
            builderResults.value = data.data.map(item => ({ ...item, loading: false }));
            if(filters.tipo === 'hotel') cachedHotels.value = builderResults.value;
        }
    } catch(e) { console.error(e); } 
    finally { builderLoading.value = false; }
};

const loadHotelRooms = async (hotel) => {
    builderLoading.value = true;
    selectedHotelName.value = hotel.nombre_elemento;
    try {
        const res = await fetch(`${API_BASE}/builder/hotel/${hotel.elemento_id}/habitaciones`);
        const data = await res.json();
        if(data.success) {
            builderResults.value = data.data.map(item => ({ ...item, loading: false }));
            viewingRoomsMode.value = true;
        }
    } catch(e) { console.error(e); }
    finally { builderLoading.value = false; }
};

const backToHotels = () => {
    builderResults.value = cachedHotels.value;
    viewingRoomsMode.value = false;
};

const toggleAssignment = async (item) => {
    item.loading = true;
    const accion = item.asignado ? 'remover' : 'aplicar';
    const tipoReal = viewingRoomsMode.value ? 'habitacion' : filters.tipo;

    try {
        const res = await fetch(`${API_BASE}/builder/${selectedPromo.value.prom_codigo}/gestion`, {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ elementoId: item.elemento_id, tipoElemento: tipoReal, accion })
        });
        const data = await res.json();
        if(data.success) item.asignado = !item.asignado; else alert(data.message);
    } catch(e) { console.error(e); }
    finally { item.loading = false; }
};

// DETALLE
const openDetailModal = async (id) => {
    detailData.value = null; showDetailModal.value = true;
    try {
        const res = await fetch(`${API_BASE}/${id}/detalles`);
        const data = await res.json();
        if(data.success) detailData.value = data.data;
    } catch(e) { console.error(e); }
};

// MODALES
const openCreateModal = () => { isEditing.value=false; Object.assign(form, {codigo:null, nombre:'', descripcion:'', descuento:0, fecha_vencimiento:''}); showFormModal.value=true; };
const openEditModal = (p) => { isEditing.value=true; Object.assign(form, {codigo:p.prom_codigo, nombre:p.prom_nombre, descripcion:p.prom_descripcion, descuento:p.prom_descuento, fecha_vencimiento: new Date(p.prom_fecha_hora_vencimiento).toISOString().slice(0,16)}); showFormModal.value=true; };

onMounted(() => fetchPromociones());
</script>

<style scoped>
/* ESTILOS EXACTOS DE PAQUETES */
.container-fluid {
    padding: 30px;
    background-color: #f8fafc;
    min-height: 100vh;
    font-family: 'Segoe UI', sans-serif;
}

.header-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 25px;
}
.header-actions h2 { color: #1e293b; margin: 0; font-weight: 700; }
.subtitle { color: #64748b; margin: 0; font-size: 0.9rem; }

/* TABLA */
.table-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
    overflow: hidden;
}
.styled-table { width: 100%; border-collapse: collapse; }
.styled-table th { background: #f1f5f9; color: #475569; padding: 16px; font-size: 0.85rem; text-transform: uppercase; font-weight: 600; text-align: left; }
.styled-table td { padding: 16px; border-bottom: 1px solid #e2e8f0; color: #334155; }
.id-tag { color: #64748b; font-weight: 600; font-size: 0.85rem; }
.font-bold { font-weight: 600; color: #0f172a; }
.text-muted { color: #94a3b8; font-size: 0.9rem; }
.amount-text { font-family: 'Consolas', monospace; color: #059669; font-weight: 700; }
.miles-tag { background: #eff6ff; color: #2563eb; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; }
.discount-tag { background: #dcfce7; color: #166534; padding: 4px 8px; border-radius: 6px; font-size: 0.8rem; font-weight: 700; }

/* BOTONES PRINCIPALES */
.btn-main { background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; display: flex; gap: 8px; align-items: center; }
.btn-main:hover { background: #1d4ed8; }
.btn-secondary { background: #e2e8f0; color: #475569; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; }
.btn-add { background: #10b981; color: white; border: none; padding: 0 20px; border-radius: 6px; font-weight: 600; cursor: pointer; white-space: nowrap; }
.btn-add:hover { background: #059669; }

/* GRUPO DE ACCIONES */
.action-group { display: flex; gap: 5px; justify-content: center; }
.action-btn { width: 32px; height: 32px; border: none; border-radius: 6px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: 0.2s; background: transparent; color: #475569; font-size: 1.2rem; }
.btn-view:hover { background: #e0f2fe; } 
.btn-config:hover { background: #fef3c7; } 
.btn-edit:hover { background: #f3e8ff; } 
.btn-delete:hover { background: #fee2e2; }

/* MODALES */
.modal-backdrop {
    position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
    background-color: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px);
    display: flex; justify-content: center; align-items: center; z-index: 1000;
}
.modal-window {
    background: white; border-radius: 16px; width: 95%; max-width: 500px;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
    display: flex; flex-direction: column; max-height: 90vh;
    animation: slideUp 0.3s ease-out;
}
.modal-window.large { max-width: 850px; }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

.modal-header { padding: 20px 24px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
.modal-header h3 { margin: 0; font-size: 1.25rem; color: #0f172a; }
.close-icon { background: none; border: none; font-size: 1.5rem; color: #94a3b8; cursor: pointer; }
.modal-body { padding: 24px; overflow-y: auto; }
.modal-footer { padding: 20px 24px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; background: #f8fafc; border-bottom-left-radius: 16px; border-bottom-right-radius: 16px; }

/* INPUTS */
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 600; color: #475569; font-size: 0.85rem; }
.input-field { width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; background: white; }
.input-field:focus { outline: none; border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1); }
.row-inputs { display: flex; gap: 15px; }
.assign-form { background: #f8fafc; padding: 20px; border-radius: 8px; border: 1px solid #e2e8f0; margin-bottom: 20px; }
.input-group-row { display: flex; gap: 10px; }
.flex-grow { flex: 1; }

/* DETALLES (ESTILO PAQUETES) */
.detail-summary { text-align: center; margin-bottom: 25px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
.detail-title { margin: 0 0 10px 0; color: #0f172a; font-size: 1.5rem; }
.price-badge { display: inline-block; padding: 6px 12px; border-radius: 20px; font-weight: 700; font-size: 1rem; }
.price-badge.main { background: #dcfce7; color: #166534; }

.detail-block { margin-bottom: 20px; }
.detail-block h5 { margin: 0 0 10px 0; color: #64748b; font-size: 0.8rem; text-transform: uppercase; border-left: 3px solid #3b82f6; padding-left: 10px; }
.detail-item {
    background: #f8fafc; border: 1px solid #e2e8f0; padding: 12px; border-radius: 8px; margin-bottom: 8px;
    font-size: 0.95rem; color: #334155;
}

/* BUILDER UTILS */
.back-bar { display: flex; align-items: center; gap: 15px; margin-bottom: 15px; background: #e0f2fe; padding: 10px; border-radius: 6px; color: #0369a1; }
.btn-view-rooms { background: #3b82f6; color: white; border: none; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; }
.empty-state-inner { text-align: center; padding: 30px; color: #94a3b8; font-style: italic; }
.loading-text { text-align: center; padding: 40px; color: #64748b; }
.small-text { font-size: 0.85rem; }
.centered-row { justify-content: center; align-items: flex-end; }
.btn-container { display: flex; align-items: flex-end; }

/* BOTONES PEQUEÑOS */
.btn-success-sm { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 0.8rem; font-weight: 600; }
.btn-danger-sm { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-size: 0.8rem; font-weight: 600; }
</style>