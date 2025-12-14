<template>
  <div class="promotion-builder">
    
    <div v-if="loading" class="loading-overlay">Cargando datos de la promoción...</div>

    <div v-else> 
      
      <header class="promo-header">
        <h1>Construir Promoción: <span class="text-blue">{{ promocion.prom_nombre }}</span></h1>
        <p class="desc-text">{{ promocion.prom_descripcion }}</p>
        <div class="promo-details">
          <span>Descuento: <strong>{{ promocion.prom_descuento }}%</strong></span>
          <span>Vencimiento: <strong>{{ formatDate(promocion.prom_fecha_hora_vencimiento) }}</strong></span>
        </div>
      </header>
      
      <hr>

      <div class="search-card">
        <h2>🔍 Buscar Elementos a Asignar</h2>
        <div class="form-row">
          <div class="form-group half">
            <label>Estado/Lugar de Ubicación</label>
            <select v-model="filters.estado" required>
              <option disabled value="">-- Seleccione un Estado --</option>
              <option v-for="estado in estados" :key="estado" :value="estado">{{ estado }}</option>
            </select>
          </div>
          
          <div class="form-group half">
            <label>Tipo de Elemento</label>
            <select v-model="filters.tipo" required>
              <option disabled value="">-- Seleccione el Tipo --</option>
              <option value="traslado_aereo">✈️ Traslado Aéreo</option>
              <option value="traslado_maritimo">🚢 Traslado Marítimo</option>
              <option value="traslado_terrestre">🚌 Traslado Terrestre</option>
              <option value="servicio">🎟️ Servicio (Actividad)</option>
              <option value="habitacion">🛏️ Habitación de Hotel</option>
              <option value="restaurante">🍽️ Restaurante</option>
            </select>
          </div>
        </div>
        <button @click="executeSearch" :disabled="!filters.estado || !filters.tipo || searchLoading" class="btn-primary">
          {{ searchLoading ? 'Buscando...' : 'Buscar Elementos' }}
        </button>
      </div>

      <div v-if="resultados.length > 0" class="results-table-container">
        <h3>Elementos Encontrados ({{ filtrosDisplay }})</h3>
        <table class="data-table">
          <thead>
            <tr>
              <th>Nombre / ID</th>
              <th>Tipo Detallado</th>
              <th>Costo / Info</th>
              <th>Fechas</th>
              <th>Detalles</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in resultados" :key="item.elemento_id">
              <td><strong>{{ item.nombre_elemento }}</strong></td>
              <td>{{ item.tipo_detallado }}</td>
              <td>
                <span v-if="item.costo">Costo: ${{ item.costo.toFixed(2) }}</span>
                <span v-else>N/A</span>
              </td>
              <td>{{ formatDateTimeRange(item.fecha_inicio, item.fecha_fin) }}</td>
              <td>
                <span v-if="item.rating">Rating: {{ '⭐'.repeat(item.rating) }}</span>
                <span v-if="item.capacidad">Capacidad: {{ item.capacidad }} pers.</span>
                <p v-if="item.info_basica">{{ item.info_basica }}</p>
              </td>
              <td>
                <button 
                  @click="toggleAssignment(item)" 
                  :class="item.asignado ? 'btn-danger-sm' : 'btn-warning-sm'"
                  :disabled="item.loading">
                  {{ item.loading ? '...' : (item.asignado ? '❌ Remover' : '✅ Aplicar') }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div v-else-if="!searchLoading && searchAttempted" class="no-results">
          No se encontraron elementos con los filtros seleccionados.
      </div>
      
    </div> </div> </template>
<script setup>
import { ref, reactive, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

const route = useRoute();
const router = useRouter();

const API_BASE_URL = '/api/promotions/builder'; 
const prom_codigo = route.params.prom_codigo;

// --- ESTADO ---
const loading = ref(true); // Se inicia en true
const searchLoading = ref(false);
const searchAttempted = ref(false);

const promocion = ref({});
const estados = ref([]);
const filters = reactive({ estado: '', tipo: '' });
const resultados = ref([]);

// --- HELPERS ---

const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleString('es-VE', { year: 'numeric', month: '2-digit', day: '2-digit' });
};

const formatDateTimeRange = (start, end) => {
    if (!start) return 'No aplica';
    const startDate = new Date(start);
    const endDate = end ? new Date(end) : null;
    
    let result = startDate.toLocaleString('es-VE', { 
        day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' 
    });
    
    if (endDate) {
        result += ' - ' + endDate.toLocaleString('es-VE', { 
            day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' 
        });
    }
    return result;
};

const filtrosDisplay = computed(() => {
    const tipoMap = {
        'traslado_aereo': 'Traslados Aéreos',
        'traslado_maritimo': 'Traslados Marítimos',
        'traslado_terrestre': 'Traslados Terrestres',
        'servicio': 'Servicios',
        'habitacion': 'Habitaciones',
        'restaurante': 'Restaurantes',
    };
    return `${tipoMap[filters.tipo] || 'Elementos'} en ${filters.estado}`;
});

// --- API Y LÓGICA ---

const fetchInitialData = async () => {
    try {
        const res = await axios.get(`${API_BASE_URL}/${prom_codigo}`);
        // Asume que res.data.promocion contiene los campos prom_nombre, prom_descripcion, etc.
        promocion.value = res.data.promocion;
        estados.value = res.data.estados;
    } catch (e) {
        console.error('Error cargando data inicial:', e);
        alert('Error al cargar la promoción o los estados.');
        router.push('/promotions'); // Redirige si falla
    } finally {
        loading.value = false; // Siempre cambia a false al terminar (éxito o error)
    }
};

const executeSearch = async () => {
    if (!filters.estado || !filters.tipo) return;
    searchLoading.value = true;
    searchAttempted.value = true;
    resultados.value = [];

    try {
        const res = await axios.get(`${API_BASE_URL}/${prom_codigo}/elementos`, {
            params: {
                estado: filters.estado,
                tipo: filters.tipo,
            }
        });
        // Inicializa un flag 'loading' en cada resultado para el botón
        resultados.value = res.data.map(item => ({ ...item, loading: false }));

    } catch (e) {
        console.error('Error al buscar elementos:', e);
        alert('Error al realizar la búsqueda.');
    } finally {
        searchLoading.value = false;
    }
};

const toggleAssignment = async (item) => {
    item.loading = true;
    const accion = item.asignado ? 'remover' : 'aplicar';

    // Normaliza el tipo para el backend (quitando aéreo, etc.)
    const tipoNormalizado = filters.tipo.startsWith('traslado') ? 'traslado' : filters.tipo;

    try {
        const res = await axios.post(`${API_BASE_URL}/${prom_codigo}/gestion`, {
            elementoId: item.elemento_id,
            tipoElemento: tipoNormalizado,
            accion: accion
        });

        alert(res.data.mensaje);
        // Actualiza el estado localmente para reflejar el cambio
        item.asignado = !item.asignado; 

    } catch (e) {
        console.error(`Error al ${accion} la promoción:`, e);
        alert(`Fallo al ${accion} la promoción: ` + (e.response?.data?.error || e.message));
    } finally {
        item.loading = false;
    }
};

// --- LIFECYCLE ---
onMounted(() => {
    if (prom_codigo) {
        fetchInitialData();
    } else {
        alert('Código de promoción no proporcionado.');
        router.push('/promotions');
    }
});
</script>

<style scoped>
/* Estilos basados en tu componente anterior, pero adaptados al layout de construcción */

.promotion-builder {
    max-width: 1200px;
    margin: 30px auto;
    padding: 20px;
    background: #f8fafc;
    border-radius: 8px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.promo-header {
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 15px;
    margin-bottom: 20px;
}

.promo-header h1 {
    font-size: 1.8rem;
    color: #1e293b;
    margin-bottom: 5px;
}

.desc-text {
    color: #64748b;
    font-size: 1rem;
    margin-bottom: 10px;
}

.promo-details span {
    display: inline-block;
    background: #e0f2f1;
    color: #0d9488;
    padding: 5px 10px;
    border-radius: 4px;
    margin-right: 15px;
    font-size: 0.9rem;
}

.search-card {
    background: white;
    padding: 20px;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    margin-bottom: 30px;
}

.search-card h2 {
    font-size: 1.4rem;
    color: #3b82f6;
    margin-bottom: 20px;
}

.form-row {
    display: flex;
    gap: 20px;
    margin-bottom: 20px;
}

.form-group.half {
    flex: 1;
}

/* Estilos de tabla para resultados */
.results-table-container {
    margin-top: 30px;
}

.results-table-container h3 {
    font-size: 1.2rem;
    margin-bottom: 15px;
    color: #475569;
}

.data-table th, .data-table td {
    padding: 10px 12px;
    font-size: 0.9rem;
    vertical-align: top;
}

.data-table th {
    background-color: #f0f4f8;
}

.data-table td {
    max-width: 150px;
    overflow-wrap: break-word;
}

.no-results {
    text-align: center;
    padding: 40px;
    background: #fff;
    border-radius: 8px;
    color: #94a3b8;
    font-size: 1.1rem;
    margin-top: 20px;
}
</style>