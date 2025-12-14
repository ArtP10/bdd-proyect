<template>
  <div>
    <div class="actions-bar">
      <button @click="openCreateModal" class="btn-primary">+ Nueva Promoción</button>
    </div>

    <table class="data-table">
      <thead>
        <tr>
          <th>Nombre</th>
          <th>Descripción</th>
          <th>Descuento</th>
          <th>Vencimiento</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="p in promociones" :key="p.prom_codigo">
          <td><strong>{{ p.prom_nombre }}</strong></td>
          <td class="desc-cell">{{ p.prom_descripcion }}</td>
          <td class="text-destacado">{{ p.prom_descuento }}%</td>
          <td>{{ formatDate(p.prom_fecha_hora_vencimiento) }}</td>
          
          <td>
              
                <button class="btn-sm" @click="editarPromocion(p)">✏️ Editar</button>
                <button class="btn-danger-sm" @click="eliminarPromocion(p.prom_codigo)">🗑️ Eliminar</button>

                <button class="btn-warning-sm" @click="goToBuilder(p.prom_codigo)">🔗 Asignar/Construir</button>
              
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="showModal" class="modal-overlay">
      <div class="modal-content">
        <h3>{{ isEditing ? 'Editar' : 'Registrar' }} Promoción</h3>
        <form @submit.prevent="savePromocion">
          
          <div class="form-section">
            <div class="form-group">
                <label>Nombre de la Promoción</label>
                <input v-model="form.nombre" required placeholder="Ej: Verano 2025" />
            </div>
            
            <div class="form-group">
                <label>Descripción</label>
                <textarea v-model="form.descripcion" required rows="3" placeholder="Detalles de la oferta..."></textarea>
            </div>

            <div class="form-row">
                <div class="form-group half">
                    <label>Descuento (%)</label>
                    <input type="number" step="0.01" min="0" max="100" v-model="form.descuento" required />
                </div>

                <div class="form-group half">
                    <label>Fecha y Hora de Vencimiento</label>
                    <input type="datetime-local" v-model="form.fecha_vencimiento" required :min="minDateTime" />
                </div>
            </div>
          </div>

          <div class="modal-actions">
            <button type="submit" class="btn-primary">{{ isEditing ? 'Actualizar' : 'Registrar' }}</button>
            <button type="button" @click="cerrarModal" class="btn-secondary">Cancelar</button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="showAssignModal" class="modal-overlay">
      <div class="modal-content">
        <h3>Asignar: <span class="text-blue">{{ selectedPromo?.prom_nombre }}</span></h3>
        <p class="desc-modal">Elige a qué elemento deseas aplicar este descuento.</p>
        
        <div class="form-section">
            <div class="form-group">
                <label>1. Tipo de Elemento</label>
                <select v-model="assignType" @change="resetSelection" class="full-select">
                    <option value="paquete">📦 Paquete Turístico</option>
                    <option value="servicio">🎟️ Servicio (Actividad, Vuelo...)</option>
                    <option value="habitacion">🛏️ Habitación de Hotel</option>
                    <option value="traslado">🚌 Traslado</option>
                </select>
            </div>

            <div class="form-group" v-if="assignType">
                <label>2. Selecciona el Item Específico</label>
                <select v-model="selectedItemId" class="full-select">
                    <option disabled value="">-- Seleccione una opción --</option>
                    <option v-for="item in currentList" :key="item.id" :value="item.id">
                        {{ item.nombre }}
                    </option>
                </select>
            </div>
        </div>

        <div class="modal-actions">
           <button @click="confirmarAsignacion" class="btn-warning" :disabled="!selectedItemId">Confirmar Asignación</button>
           <button @click="showAssignModal = false" class="btn-secondary">Cancelar</button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router'; // Importar useRouter para la redirección
import axios from 'axios'; 

// --- Inicialización ---
const router = useRouter(); // Inicializamos el router para la navegación

// --- ESTADO GENERAL ---
const API_URL = 'http://localhost:3000/api/promociones';
const promociones = ref([]);

// --- ESTADO MODAL CREAR/EDITAR ---
const showModal = ref(false);
const isEditing = ref(false);
const form = reactive({ codigo: null, nombre: '', descripcion: '', descuento: 0, fecha_vencimiento: '' });

// ❌ Se eliminan todas las variables y funciones relacionadas con el viejo modal de asignación:
// ❌ showAssignModal, selectedPromo, assignType, selectedItemId, listas, currentList, fetchListasAsignacion, abrirModalAsignar, resetSelection, confirmarAsignacion.

// --- HELPERS ---
const minDateTime = computed(() => {
    const now = new Date();
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    return now.toISOString().slice(0, 16);
});

const formatDate = (dateString) => {
    if(!dateString) return '';
    // Usamos el mismo formato que ya tenías
    return new Date(dateString).toLocaleString('es-VE', { 
        year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute:'2-digit' 
    });
};

// --- API FETCH ---
const fetchPromociones = async () => {
    try {
        const res = await axios.get(API_URL);
        promociones.value = res.data; 
    } catch(e) { console.error("Error fetching:", e); }
};

// --- LOGICA CRUD ---
const savePromocion = async () => {
    try {
        if (isEditing.value) {
            await axios.put(`${API_URL}/${form.codigo}`, form);
            alert('Promoción actualizada');
        } else {
            await axios.post(API_URL, form);
            alert('Promoción creada');
        }
        cerrarModal();
        fetchPromociones();
    } catch(e) { 
        console.error(e); 
        alert('Error al guardar: ' + (e.response?.data?.error || e.message));
    }
};

const eliminarPromocion = async (id) => {
    if(!confirm('¿Estás seguro de eliminar esta promoción?')) return;
    try {
        await axios.delete(`${API_URL}/${id}`);
        fetchPromociones();
    } catch(e) { console.error(e); alert('Error al eliminar'); }
};

// --- LOGICA DE REDIRECCIÓN (NUEVA) ---
const goToBuilder = (prom_codigo) => {
    // Redirecciona al nuevo componente PromotionBuilder
    router.push(`/promotions/build-promotion/${prom_codigo}`); 
};


// --- MODAL CONTROLS ---
const openCreateModal = () => {
    isEditing.value = false;
    Object.assign(form, { codigo: null, nombre: '', descripcion: '', descuento: 0, fecha_vencimiento: '' });
    showModal.value = true;
};

const editarPromocion = (prom) => {
    isEditing.value = true;
    const fechaISO = new Date(prom.prom_fecha_hora_vencimiento).toISOString().slice(0, 16);
    Object.assign(form, {
        codigo: prom.prom_codigo,
        nombre: prom.prom_nombre,
        descripcion: prom.prom_descripcion,
        descuento: prom.prom_descuento,
        fecha_vencimiento: fechaISO
    });
    showModal.value = true;
};

const cerrarModal = () => {
    showModal.value = false;
};

onMounted(() => {
    fetchPromociones();
});
</script>

<style scoped>
/* ESTILOS GENERALES */
.actions-bar { margin-bottom: 20px; text-align: right; }
.data-table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
.data-table th, .data-table td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; }
.data-table th { background-color: #f8fafc; font-weight: 600; color: #475569; }

.text-destacado { font-weight: bold; color: #3b82f6; font-size: 1.1em; }
.desc-cell { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #64748b; }

/* BOTONES */
.btn-primary { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; transition: 0.2s; }
.btn-primary:hover { background: #2563eb; }
.btn-secondary { background: #94a3b8; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }

.btn-sm { padding: 5px 10px; font-size: 0.8rem; margin-right: 5px; cursor: pointer; background: #e2e8f0; border: none; border-radius: 4px; }
.btn-danger-sm { padding: 5px 10px; font-size: 0.8rem; background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; cursor: pointer; border-radius: 4px; margin-right: 5px; }

/* NUEVOS BOTONES (Amarillo para Asignar) */
.btn-warning-sm { background: #f59e0b; color: white; border: none; padding: 5px 10px; font-size: 0.8rem; border-radius: 4px; cursor: pointer; }
.btn-warning-sm:hover { background: #d97706; }
.btn-warning { background: #f59e0b; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
.btn-warning:disabled { background: #fcd34d; cursor: not-allowed; }

/* MODAL */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-content { background: white; padding: 25px; border-radius: 8px; width: 500px; max-height: 90vh; overflow-y: auto; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }

.form-section { margin-bottom: 15px; }
.form-group { margin-bottom: 15px; }
.form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 0.9rem; color: #334155; }
.form-group input, .form-group textarea, .full-select { width: 100%; padding: 8px 10px; border: 1px solid #cbd5e1; border-radius: 4px; box-sizing: border-box; font-family: inherit; }
.full-select { background-color: white; }
.form-group textarea { resize: vertical; }

.form-row { display: flex; gap: 15px; }
.half { flex: 1; }

.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; border-top: 1px solid #eee; padding-top: 15px; }
.text-blue { color: #3b82f6; }
.desc-modal { color: #64748b; font-size: 0.9rem; margin-bottom: 20px; }
</style>