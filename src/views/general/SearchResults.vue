<template>
  <div class="results-container">
    <header class="results-header">
      <div class="container header-content">
        <div class="logo-area" @click="$router.push('/')">
          <i class="fa-solid fa-paper-plane"></i> Viajes UCAB
        </div>
        
        <div class="search-summary">
          <div class="summary-pill">
            <i class="fa-solid fa-location-dot"></i>
            {{ route.query.destino || 'Cualquier destino' }}
          </div>
          <div class="summary-pill" v-if="route.query.fecha">
            <i class="fa-regular fa-calendar"></i>
            {{ formatDate(route.query.fecha) }}
          </div>
        </div>
      </div>
    </header>

    <div class="container main-layout">
      
      <div class="results-top-bar">
        <h2>Resultados para {{ route.query.destino || 'tu búsqueda' }}</h2>
        <span class="count-badge">{{ results.length }} opciones encontradas</span>
      </div>

      <div v-if="loading" class="loading-state">
        <i class="fa-solid fa-circle-notch fa-spin"></i> Buscando las mejores ofertas...
      </div>

      <div v-else-if="results.length === 0" class="no-results">
        <img src="https://cdn-icons-png.flaticon.com/512/6134/6134065.png" alt="No found" width="100">
        <h3>No encontramos resultados</h3>
        <p>Intenta cambiar las fechas o el destino.</p>
        <button class="btn btn-primary" @click="$router.push('/')">Volver al inicio</button>
      </div>

      <div v-else class="cards-list">
        <div v-for="item in results" :key="item.id + item.categoria" class="result-card">
          
          <div class="card-left">
            <div class="img-placeholder">
              <i :class="getIconClass(item.subtipo)"></i>
            </div>
          </div>

          <div class="card-center">
            <div class="card-tag">{{ item.subtipo || item.categoria }}</div>
            <h3 class="card-title">{{ item.titulo }}</h3>
            
            <div class="route-info">
              <p class="location-detail">{{ item.detalle_lugar }}</p>
            </div>

            <div class="time-info">
              <div class="time-block">
                <span class="label">Fecha</span>
                <span class="value">{{ formatDate(item.fecha_inicio) }}</span>
              </div>
              <div class="time-block">
                <span class="label">Hora</span>
                <span class="value">{{ formatTime(item.fecha_inicio) }}</span>
              </div>
            </div>
          </div>

          <div class="card-right">
            <div class="price-container">
              <span class="currency">US$</span>
              <span class="amount">{{ item.precio }}</span>
            </div>
            <div class="actions">
              <button class="btn btn-primary btn-block">Seleccionar</button>
              <button class="btn btn-outline btn-block">Ver detalles</button>
            </div>
          </div>

        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const results = ref([]);
const loading = ref(true);

onMounted(async () => {
  await fetchResults();
});

const fetchResults = async () => {
  loading.value = true;
  try {
    // Tomamos los query params de la URL y los enviamos al backend
    const searchParams = {
      origen: route.query.origen,
      destino: route.query.destino,
      fecha: route.query.fecha,
      tipo: route.query.tipo
    };

    const res = await fetch('http://localhost:3000/api/home/search', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(searchParams)
    });

    const data = await res.json();
    if (data.success) {
      results.value = data.results;
    }
  } catch (error) {
    console.error("Error cargando resultados", error);
  } finally {
    loading.value = false;
  }
};

// --- Helpers de Formato y Estilo ---

const getIconClass = (subtipo) => {
  if (!subtipo) return 'fa-solid fa-star';
  const t = subtipo.toLowerCase();
  if (t.includes('aerea') || t.includes('vuelo')) return 'fa-solid fa-plane';
  if (t.includes('maritima') || t.includes('barco')) return 'fa-solid fa-ship';
  if (t.includes('terrestre')) return 'fa-solid fa-bus';
  if (t.includes('hotel') || t.includes('alojamiento')) return 'fa-solid fa-hotel';
  if (t.includes('tour') || t.includes('actividad')) return 'fa-solid fa-camera-retro';
  return 'fa-solid fa-ticket';
};

const formatDate = (dateString) => {
  if (!dateString) return '';
  const d = new Date(dateString);
  return d.toLocaleDateString('es-VE', { day: 'numeric', month: 'short', year: 'numeric' });
};

const formatTime = (dateString) => {
  if (!dateString) return '';
  const d = new Date(dateString);
  return d.toLocaleTimeString('es-VE', { hour: '2-digit', minute: '2-digit' });
};
</script>

<style scoped>
/* --- ESTILOS GENERALES (Coherentes con HomePage) --- */
.results-container {
  background-color: #F5F7FA;
  min-height: 100vh;
  font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  color: #333;
}

.container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 20px;
}

/* --- HEADER --- */
.results-header {
  background: white;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  padding: 1rem 0;
  margin-bottom: 2rem;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo-area {
  font-size: 1.4rem;
  font-weight: 800;
  color: #00BCD4; /* Cyan */
  cursor: pointer;
}

.search-summary {
  display: flex;
  gap: 10px;
}

.summary-pill {
  background: #E0F7FA;
  color: #00838F;
  padding: 5px 15px;
  border-radius: 20px;
  font-size: 0.9rem;
  font-weight: 600;
}

/* --- TÍTULO --- */
.results-top-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.results-top-bar h2 {
  font-size: 1.5rem;
  color: #2c3e50;
  margin: 0;
}

.count-badge {
  color: #666;
  font-size: 0.9rem;
}

/* --- TARJETAS DE RESULTADOS (Layout tipo Avianca/Expedia) --- */
.cards-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
  padding-bottom: 40px;
}

.result-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
  display: flex;
  padding: 20px;
  transition: transform 0.2s, box-shadow 0.2s;
  border: 1px solid transparent;
}

.result-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.08);
  border-color: #E0F7FA;
}

/* Izquierda: Imagen/Icono */
.card-left {
  width: 120px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-right: 1px solid #f0f0f0;
  padding-right: 20px;
  margin-right: 20px;
}

.img-placeholder {
  width: 80px;
  height: 80px;
  background-color: #f5f5f5;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2rem;
  color: #E91E63; /* Pink */
}

/* Centro: Información */
.card-center {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.card-tag {
  display: inline-block;
  background: #FCE4EC; /* Rosa claro */
  color: #C2185B;
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: 4px;
  width: fit-content;
  margin-bottom: 5px;
  font-weight: 700;
  text-transform: uppercase;
}

.card-title {
  font-size: 1.2rem;
  font-weight: 700;
  margin: 0 0 5px 0;
  color: #333;
}

.location-detail {
  color: #666;
  font-size: 0.95rem;
  margin-bottom: 10px;
}

.time-info {
  display: flex;
  gap: 20px;
}

.time-block .label {
  display: block;
  font-size: 0.75rem;
  color: #999;
  text-transform: uppercase;
}
.time-block .value {
  font-weight: 600;
  color: #333;
}

/* Derecha: Precio y Botones */
.card-right {
  width: 180px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: flex-end;
  padding-left: 20px;
  border-left: 1px solid #f0f0f0;
}

.price-container {
  text-align: right;
}

.currency {
  font-size: 0.9rem;
  font-weight: 600;
  color: #666;
  margin-right: 2px;
}

.amount {
  font-size: 1.8rem;
  font-weight: 800;
  color: #E91E63; /* Precio en Rosa */
}

.actions {
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Botones */
.btn {
  padding: 8px 16px;
  border-radius: 6px;
  border: none;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.9rem;
}

.btn-block {
  width: 100%;
}

/* Botón "Seleccionar" (Rosa lleno) */
.btn-primary {
  background-color: #E91E63;
  color: white;
}
.btn-primary:hover {
  background-color: #D81B60;
}

/* Botón "Ver detalles" (Outline Cyan) */
.btn-outline {
  background-color: transparent;
  border: 1px solid #00BCD4;
  color: #00BCD4;
}
.btn-outline:hover {
  background-color: #E0F7FA;
}

/* Loading & Empty States */
.loading-state, .no-results {
  text-align: center;
  padding: 4rem;
  color: #888;
}
.loading-state i {
  color: #00BCD4;
  margin-right: 10px;
}
.no-results button {
  margin-top: 1rem;
}

/* Responsividad simple */
@media (max-width: 768px) {
  .result-card {
    flex-direction: column;
    text-align: center;
  }
  .card-left, .card-right {
    width: 100%;
    border: none;
    padding: 0;
    margin: 0;
  }
  .card-left {
    margin-bottom: 15px;
    justify-content: center;
  }
  .card-right {
    margin-top: 15px;
    align-items: center;
  }
  .actions {
    margin-top: 10px;
  }
  .time-info {
    justify-content: center;
  }
  .card-tag {
    margin: 0 auto 5px auto;
  }
}
</style>