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
        <button class="btn btn-primary" @click="$router.push('/home')">Volver al inicio</button>
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
              <button class="btn btn-primary btn-block" @click="handleItemSelection(item)">Seleccionar</button>
              
              <button class="btn btn-text-reviews" @click="openReviewsModal(item)">
                  <i class="fa-solid fa-star"></i> Ver Opiniones
              </button>
              
              <button class="btn btn-outline btn-block" @click="handleItemSelection(item)">Ver detalles</button>
            </div>
          </div>

        </div>
      </div>

    </div>

    <div v-if="showLoginModal" class="modal-overlay">
      <div class="modal-content">
        <div class="modal-icon">
            <i class="fa-solid fa-user-lock"></i>
        </div>
        <h3>Acceso Requerido</h3>
        <p>Inicie sesión como cliente para comenzar a agregar cosas a su carrito.</p>
        <div class="modal-actions">
          <button class="btn btn-outline" @click="closeModal">Cancelar</button>
          <button class="btn btn-primary" @click="goToLogin">Continuar</button>
        </div>
      </div>
    </div>

    <div v-if="showReviewsModal" class="modal-overlay" @click.self="closeReviewsModal">
        <div class="modal-content reviews-modal">
            <div class="modal-header-simple">
                <h3>Reseñas de {{ selectedProductTitle }}</h3>
                <button class="close-btn" @click="closeReviewsModal">✕</button>
            </div>
            
            <div v-if="loadingReviews" class="loading-box">
                <i class="fa-solid fa-spinner fa-spin"></i> Cargando opiniones...
            </div>

            <div v-else-if="productReviews.length === 0" class="empty-reviews">
                <i class="fa-regular fa-comment-dots"></i>
                <p>Este producto aún no tiene reseñas.</p>
            </div>

            <div v-else class="reviews-list">
                <div v-for="(review, index) in productReviews" :key="index" class="review-item">
                    <div class="review-top">
                        <span class="author-name">{{ review.viajero_nombre || review.autor }}</span>
                        <span class="review-date">{{ formatDate(review.fecha) }}</span>
                    </div>
                    <div class="star-row">
                        <StarRating :modelValue="review.calificacion" :readonly="true" />
                    </div>
                    <p class="review-body">"{{ review.comentario }}"</p>
                </div>
            </div>
        </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
// Importamos StarRating
import StarRating from '../components/common/StarRating.vue'; 

const route = useRoute();
const router = useRouter();
const results = ref([]);
const loading = ref(true);
const showLoginModal = ref(false);

// Variables de Reseñas
const showReviewsModal = ref(false);
const productReviews = ref([]);
const loadingReviews = ref(false);
const selectedProductTitle = ref('');

onMounted(async () => {
  await fetchResults();
});

const fetchResults = async () => {
  loading.value = true;
  try {
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

// --- LÓGICA DE RESEÑAS ---
const openReviewsModal = async (item) => {
    selectedProductTitle.value = item.titulo;
    showReviewsModal.value = true;
    loadingReviews.value = true;
    productReviews.value = [];

    // Normalizar Tipo (Search Results usualmente trae 'categoria' o 'subtipo')
    let type = item.categoria || item.subtipo || 'SERVICIO';
    type = type.toUpperCase();
    
    if(type.includes('TRASLADO')) type = 'TRASLADO';
    else if(type.includes('PAQUETE')) type = 'PAQUETE';
    else type = 'SERVICIO';

    try {
        const res = await fetch(`http://localhost:3000/api/reviews/product/${type}/${item.id}`);
        const data = await res.json();
        if(data.success) {
            productReviews.value = data.data;
        }
    } catch(e) {
        console.error("Error cargando reseñas", e);
    } finally {
        loadingReviews.value = false;
    }
};

const closeReviewsModal = () => { showReviewsModal.value = false; };

// --- HELPERS Y NAVEGACIÓN ---
const handleItemSelection = (item) => {
    const userRole = localStorage.getItem('userRole'); 
    if (userRole === 'Cliente') router.push('/client/cart');
    else showLoginModal.value = true;
};
const closeModal = () => showLoginModal.value = false;
const goToLogin = () => { showLoginModal.value = false; router.push('/login'); };

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
/* ESTILOS GENERALES */
.results-container { background-color: #F5F7FA; min-height: 100vh; font-family: 'Segoe UI', sans-serif; color: #333; }
.container { max-width: 1000px; margin: 0 auto; padding: 0 20px; }

/* HEADER */
.results-header { background: white; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 1rem 0; margin-bottom: 2rem; }
.header-content { display: flex; justify-content: space-between; align-items: center; }
.logo-area { font-size: 1.4rem; font-weight: 800; color: #00BCD4; cursor: pointer; }
.search-summary { display: flex; gap: 10px; }
.summary-pill { background: #E0F7FA; color: #00838F; padding: 5px 15px; border-radius: 20px; font-size: 0.9rem; font-weight: 600; }

/* LISTA DE RESULTADOS */
.results-top-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.results-top-bar h2 { font-size: 1.5rem; color: #2c3e50; margin: 0; }
.count-badge { color: #666; font-size: 0.9rem; }

.cards-list { display: flex; flex-direction: column; gap: 20px; padding-bottom: 40px; }
.result-card { background: white; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); display: flex; padding: 20px; transition: transform 0.2s, box-shadow 0.2s; border: 1px solid transparent; }
.result-card:hover { transform: translateY(-2px); box-shadow: 0 8px 20px rgba(0,0,0,0.08); border-color: #E0F7FA; }

.card-left { width: 120px; display: flex; align-items: center; justify-content: center; border-right: 1px solid #f0f0f0; padding-right: 20px; margin-right: 20px; }
.img-placeholder { width: 80px; height: 80px; background-color: #f5f5f5; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: #E91E63; }

.card-center { flex: 1; display: flex; flex-direction: column; justify-content: center; }
.card-tag { display: inline-block; background: #FCE4EC; color: #C2185B; font-size: 0.75rem; padding: 2px 8px; border-radius: 4px; width: fit-content; margin-bottom: 5px; font-weight: 700; text-transform: uppercase; }
.card-title { font-size: 1.2rem; font-weight: 700; margin: 0 0 5px 0; color: #333; }
.location-detail { color: #666; font-size: 0.95rem; margin-bottom: 10px; }
.time-info { display: flex; gap: 20px; }
.time-block .label { display: block; font-size: 0.75rem; color: #999; text-transform: uppercase; }
.time-block .value { font-weight: 600; color: #333; }

.card-right { width: 180px; display: flex; flex-direction: column; justify-content: space-between; align-items: flex-end; padding-left: 20px; border-left: 1px solid #f0f0f0; }
.price-container { text-align: right; }
.currency { font-size: 0.9rem; font-weight: 600; color: #666; margin-right: 2px; }
.amount { font-size: 1.8rem; font-weight: 800; color: #E91E63; }
.actions { width: 100%; display: flex; flex-direction: column; gap: 8px; }

/* BOTONES */
.btn { padding: 8px 16px; border-radius: 6px; border: none; font-weight: 600; cursor: pointer; transition: all 0.2s; font-size: 0.9rem; }
.btn-block { width: 100%; }
.btn-primary { background-color: #E91E63; color: white; }
.btn-primary:hover { background-color: #D81B60; }
.btn-outline { background-color: transparent; border: 1px solid #00BCD4; color: #00BCD4; }
.btn-outline:hover { background-color: #E0F7FA; }
.btn-text-reviews { background: transparent; color: #fbbf24; border: 1px solid #fbbf24; border-radius: 6px; }
.btn-text-reviews:hover { background: #fffbeb; }

/* ESTILOS MODAL (Igual a HomePage) */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0, 0, 0, 0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; backdrop-filter: blur(4px); }
.reviews-modal { background: white; border-radius: 12px; width: 90%; max-width: 500px; text-align: center; box-shadow: 0 10px 25px rgba(0,0,0,0.2); animation: modalPop 0.3s ease-out; overflow: hidden; }
.modal-header-simple { display: flex; justify-content: space-between; align-items: center; padding: 15px 20px; background: #f9fafb; border-bottom: 1px solid #e5e7eb; }
.modal-header-simple h3 { margin: 0; font-size: 1.1rem; color: #1f2937; }
.close-btn { background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #9ca3af; }
.loading-box, .empty-reviews { padding: 40px; text-align: center; color: #6b7280; }
.reviews-list { padding: 20px; max-height: 400px; overflow-y: auto; text-align: left; }
.review-item { margin-bottom: 15px; border-bottom: 1px solid #f0f0f0; padding-bottom: 15px; }
.review-item:last-child { border-bottom: none; }
.review-top { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 0.9rem; }
.author-name { font-weight: 700; color: #374151; }
.review-date { color: #9ca3af; font-size: 0.8rem; }
.review-body { color: #4b5563; font-style: italic; margin-top: 5px; line-height: 1.4; }

@keyframes modalPop { from { opacity: 0; transform: scale(0.9); } to { opacity: 1; transform: scale(1); } }
</style>