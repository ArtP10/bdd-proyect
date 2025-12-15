<template>
  <div class="home-container">
    <header class="main-header">
      <div class="logo-container">
        <i class="fa-solid fa-paper-plane logo-icon"></i>
        <span class="logo-text">Viajes UCAB</span>
      </div>
      <div class="header-actions">
        
        <template v-if="isLoggedIn">
           <button class="btn btn-primary btn-360" @click="goToDashboard">
             <i class="fa-solid fa-circle-user"></i> Perfil del Viajero 360°
           </button>
        </template>
        
        <template v-else>
           <button class="btn btn-outline" @click="$router.push('/client/register')">
             Crear cuenta
           </button>
           <button class="btn btn-primary" @click="$router.push('/login')">
             <i class="fa-solid fa-user"></i> Iniciar Sesión
           </button>
        </template>

      </div>
    </header>

    <div class="hero-section">
      <div class="hero-content">
        <h1>Descubre tu próxima experiencia</h1>
        <p class="hero-subtitle">Vuelos, cruceros, traslados y los mejores servicios turísticos</p>
        
        <div class="search-card">
          <div class="filter-tabs">
            <label class="tab-radio">
              <input type="radio" value="Ambos" v-model="searchFilters.tipo">
              <span>Todo</span>
            </label>
            <label class="tab-radio">
              <input type="radio" value="Traslados" v-model="searchFilters.tipo">
              <span>Traslados</span>
            </label>
            <label class="tab-radio">
              <input type="radio" value="Servicios" v-model="searchFilters.tipo">
              <span>Servicios</span>
            </label>
          </div>

          <div class="search-inputs-row">
            <div class="input-wrapper" v-if="searchFilters.tipo !== 'Servicios'">
              <label>Origen</label>
              <div class="input-group">
                <i class="fa-solid fa-plane-departure icon"></i>
                <input type="text" v-model="searchFilters.origen" placeholder="¿Desde dónde?">
              </div>
            </div>

            <div class="input-wrapper">
              <label>Destino / Lugar</label>
              <div class="input-group">
                <i class="fa-solid fa-location-dot icon"></i>
                <input type="text" v-model="searchFilters.destino" placeholder="¿A dónde vas?">
              </div>
            </div>

            <div class="input-wrapper">
              <label>Fecha</label>
              <div class="input-group">
                <input type="date" v-model="searchFilters.fecha">
              </div>
            </div>

            <button class="btn btn-primary btn-search" @click="handleSearch">
              <i class="fa-solid fa-magnifying-glass"></i> Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="isSearching" class="results-section container">
      <div class="section-header">
        <h2>Resultados encontrados</h2>
        <button @click="clearSearch" class="btn-text">Limpiar filtros <i class="fa-solid fa-xmark"></i></button>
      </div>
      
      <div v-if="searchResults.length === 0" class="no-results">
        <i class="fa-regular fa-face-sad-tear"></i>
        <p>No encontramos ofertas con esos criterios.</p>
      </div>

      <div class="cards-grid">
        <div v-for="item in searchResults" :key="item.id + item.categoria" class="card result-card">
          <div class="card-image-placeholder">
            <i :class="getIconClass(item.subtipo)"></i>
          </div>
          <div class="card-body">
            <div class="card-badge">{{ item.subtipo || item.categoria }}</div>
            <h3>{{ item.titulo }}</h3>
            <p class="date"><i class="fa-regular fa-calendar"></i> {{ formatDate(item.fecha_inicio) }}</p>
            <p class="location">{{ item.detalle_lugar }}</p>
            <div class="card-footer">
              <div class="price">${{ item.precio }}</div>
              <button class="btn btn-sm btn-primary" @click="handleItemSelection(item)">Ver Detalle</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-else class="main-content container">
      
      <section class="carousel-section">
        <div class="section-header">
          <h2><span class="highlight-text">¡No te lo pierdas!</span> Próximas salidas</h2>
          <a href="#" class="view-all">Ver todo</a>
        </div>
        
        <div class="cards-scroll">
          <div v-for="item in proximos" :key="item.id + item.tipo_recurso" class="card vertical-card">
            <div class="status-tag">Próximo</div>
            <div class="card-icon-header">
              <i :class="getIconClass(item.subtipo)"></i>
            </div>
            <div class="card-body">
              <h4>{{ item.titulo }}</h4>
              <p class="meta-date">{{ formatDate(item.fecha_inicio) }}</p>
              <p class="sub-text"><i class="fa-solid fa-map-pin"></i> {{ item.ubicacion }}</p>
              <div class="price-row">
                <span class="price-label">Desde</span>
                <span class="price-value">${{ item.precio }}</span>
              </div>
              <button class="btn btn-sm btn-primary mt-2" style="width:100%" @click="handleItemSelection(item)">Reservar</button>
            </div>
          </div>
        </div>
      </section>

      <section class="carousel-section bg-white-section">
        <div class="section-header">
          <h2><i class="fa-solid fa-route secondary-color"></i> Traslados Más Populares</h2>
        </div>
        <div class="cards-scroll">
          <div v-for="t in topTraslados" :key="t.id" class="card horizontal-card">
            <div class="h-icon-side">
              <i :class="getIconClass(t.tipo)"></i>
            </div>
            <div class="h-info-side">
              <h4>{{ t.titulo }}</h4> <p class="desc-text">{{ t.descripcion }}</p>
              <div class="h-footer">
                <span class="sales-badge"><i class="fa-solid fa-fire"></i> {{ t.total_ventas }} vendidos</span>
                <div style="display:flex; gap:10px; align-items:center;">
                    <span class="h-price">${{ t.precio }}</span>
                    <button class="btn btn-sm btn-primary" @click="handleItemSelection(t)">Ver</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="carousel-section">
        <div class="section-header">
          <h2><i class="fa-solid fa-umbrella-beach secondary-color"></i> Experiencias Top</h2>
        </div>
        <div class="cards-grid">
          <div v-for="s in topServicios" :key="s.id" class="card service-card">
            <div class="service-img-mock">
              <i class="fa-solid fa-camera"></i>
            </div>
            <div class="card-body">
              <div class="category-pill">{{ s.subtipo }}</div>
              <h4>{{ s.titulo }}</h4>
              <p class="location"><i class="fa-solid fa-location-arrow"></i> {{ s.lugar }}</p>
              <div class="card-footer">
                <div class="price">${{ s.precio }}</div>
                <button class="btn-icon-only" @click="handleItemSelection(s)"><i class="fa-solid fa-arrow-right"></i></button>
              </div>
            </div>
          </div>
        </div>
      </section>
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

  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import { useRouter } from 'vue-router'; 
const router = useRouter();

const topTraslados = ref([]);
const topServicios = ref([]);
const proximos = ref([]);
const searchResults = ref([]);
const isSearching = ref(false);

// Variables de Estado
const isLoggedIn = ref(false);
const showLoginModal = ref(false);

const searchFilters = reactive({
  origen: '',
  destino: '',
  fecha: '',
  tipo: 'Ambos'
});

onMounted(async () => {
  // 1. Verificar Sesión al cargar
  const session = localStorage.getItem('user_session');
  const role = localStorage.getItem('userRole');
  
  if (session && role === 'Cliente') {
      isLoggedIn.value = true;
  }

  // 2. Cargar Datos del Backend
  try {
    const res = await fetch('http://localhost:3000/api/home/get-home-data');
    const data = await res.json();
    if(data.success) {
      topTraslados.value = data.data.topTraslados;
      topServicios.value = data.data.topServicios;
      proximos.value = data.data.proximos;
    }
  } catch (e) {
    console.error("Error cargando home", e);
  }
});

// --- LÓGICA DE NAVEGACIÓN ---
const goToDashboard = () => {
    router.push('/client/dashboard');
};

const handleItemSelection = (item) => {
    if (isLoggedIn.value) {
        // Usuario logueado -> Ir al carrito
        router.push('/client/cart');
    } else {
        // Usuario anónimo -> Mostrar modal
        showLoginModal.value = true;
    }
};

const closeModal = () => {
    showLoginModal.value = false;
};

const goToLogin = () => {
    showLoginModal.value = false;
    router.push('/login');
};

const handleSearch = () => {
  router.push({
    name: 'results',
    query: {
      origen: searchFilters.origen,
      destino: searchFilters.destino,
      fecha: searchFilters.fecha,
      tipo: searchFilters.tipo
    }
  });
};

const clearSearch = () => {
  isSearching.value = false;
  searchResults.value = [];
  searchFilters.origen = '';
  searchFilters.destino = '';
  searchFilters.fecha = '';
};

// --- Helpers ---
const getIconClass = (tipo) => {
  if (!tipo) return 'fa-solid fa-star';
  const t = tipo.toLowerCase();
  if (t.includes('aerea') || t.includes('avion')) return 'fa-solid fa-plane-up';
  if (t.includes('maritima') || t.includes('barco') || t.includes('crucero')) return 'fa-solid fa-ship';
  if (t.includes('terrestre') || t.includes('bus')) return 'fa-solid fa-bus';
  if (t.includes('hotel') || t.includes('alojamiento')) return 'fa-solid fa-hotel';
  if (t.includes('tour')) return 'fa-solid fa-camera-retro';
  return 'fa-solid fa-ticket'; 
};

const formatDate = (dateString) => {
  if(!dateString) return '';
  const d = new Date(dateString);
  return d.toLocaleDateString('es-VE', { day: 'numeric', month: 'short', year:'numeric' });
};
</script>

<style scoped>
/* --- ESTILOS GENERALES --- */
.home-container {
  font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  background-color: #F5F7FA;
  min-height: 100vh;
  color: #333;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* --- HEADER --- */
.main-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  background: white;
  box-shadow: 0 2px 10px rgba(0,0,0,0.03);
  position: sticky;
  top: 0;
  z-index: 90;
}

.logo-container {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #00BCD4;
  font-size: 1.5rem;
  font-weight: 700;
}

.header-actions {
  display: flex;
  gap: 15px;
}

/* --- BOTONES --- */
.btn {
  padding: 0.6rem 1.2rem;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.95rem;
}

.btn-primary {
  background-color: #E91E63; 
  color: white;
  box-shadow: 0 4px 6px rgba(233, 30, 99, 0.2);
}
.btn-primary:hover {
  background-color: #d81b60;
  transform: translateY(-1px);
}

/* Botón Especial Perfil 360 */
.btn-360 {
    background: linear-gradient(90deg, #ec4899, #8b5cf6); /* Gradiente morado/rosa */
    border: none;
    box-shadow: 0 4px 10px rgba(236, 72, 153, 0.3);
    display: flex;
    align-items: center;
    gap: 8px;
}
.btn-360:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 15px rgba(236, 72, 153, 0.5);
}

.btn-outline {
  background-color: transparent;
  border: 2px solid #00BCD4;
  color: #00BCD4;
}
.btn-outline:hover {
  background-color: #00BCD4;
  color: white;
}

.btn-sm { padding: 0.4rem 0.8rem; font-size: 0.85rem; }
.btn-text { background: none; color: #666; text-decoration: underline; border: none; cursor: pointer;}
.mt-2 { margin-top: 10px; }

/* --- HERO SECTION --- */
.hero-section {
  background: linear-gradient(135deg, #00BCD4 0%, #0097a7 100%);
  padding: 4rem 1rem 6rem 1rem;
  text-align: center;
  color: white;
  margin-bottom: 4rem;
}

.hero-content h1 { font-size: 2.5rem; margin-bottom: 0.5rem; font-weight: 800; }
.hero-subtitle { font-size: 1.1rem; opacity: 0.9; margin-bottom: 2rem; }

/* --- TARJETA DE BÚSQUEDA --- */
.search-card {
  background: white;
  border-radius: 16px;
  padding: 1.5rem 2rem;
  max-width: 1000px;
  margin: 0 auto;
  box-shadow: 0 15px 30px rgba(0,0,0,0.1);
  position: relative;
  top: 20px;
  color: #333;
  text-align: left;
}

.filter-tabs { display: flex; gap: 20px; margin-bottom: 1.5rem; border-bottom: 1px solid #eee; padding-bottom: 1rem; }
.tab-radio { cursor: pointer; display: flex; align-items: center; gap: 8px; font-weight: 600; color: #666; }
.tab-radio input { accent-color: #E91E63; }

.search-inputs-row { display: flex; align-items: flex-end; gap: 15px; flex-wrap: wrap; }
.input-wrapper { flex: 1; min-width: 200px; }
.input-wrapper label { display: block; font-size: 0.8rem; font-weight: 700; color: #888; margin-bottom: 5px; text-transform: uppercase; }

.input-group {
  display: flex;
  align-items: center;
  background: #F5F7FA;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 0.7rem;
  transition: border 0.2s;
}
.input-group:focus-within { border-color: #00BCD4; background: white; }
.input-group input { border: none; background: transparent; width: 100%; outline: none; margin-left: 10px; font-size: 1rem; color: #333; }
.input-group .icon { color: #00BCD4; }

.btn-search { height: 50px; padding-left: 2rem; padding-right: 2rem; font-size: 1.1rem; }

/* --- SECCIONES Y TARJETAS --- */
.carousel-section { margin-bottom: 4rem; }
.section-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 1.5rem; }
.section-header h2 { font-size: 1.5rem; color: #2c3e50; margin: 0; }
.highlight-text { color: #E91E63; }
.secondary-color { color: #00BCD4; margin-right: 8px; }
.view-all { color: #00BCD4; text-decoration: none; font-weight: 600; }

.cards-scroll { display: flex; overflow-x: auto; gap: 20px; padding: 10px 5px 20px 5px; }
.cards-scroll::-webkit-scrollbar { height: 6px; }
.cards-scroll::-webkit-scrollbar-thumb { background: #ccc; border-radius: 10px; }

.card {
  background: white;
  border-radius: 16px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.05);
  overflow: hidden;
  transition: transform 0.3s, box-shadow 0.3s;
  border: 1px solid rgba(0,0,0,0.02);
}
.card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }

.vertical-card { min-width: 260px; position: relative; }
.status-tag { position: absolute; top: 10px; right: 10px; background: #E91E63; color: white; font-size: 0.7rem; padding: 4px 8px; border-radius: 20px; font-weight: bold; text-transform: uppercase; }
.card-icon-header { height: 120px; background: #E0F7FA; display: flex; align-items: center; justify-content: center; font-size: 3rem; color: #00BCD4; }
.card-body { padding: 1.2rem; }
.card-body h4 { margin: 0 0 0.5rem 0; font-size: 1.1rem; }
.meta-date { color: #E91E63; font-weight: 600; font-size: 0.9rem; margin-bottom: 0.5rem; }
.sub-text { color: #666; font-size: 0.9rem; margin-bottom: 1rem; }
.price-row { display: flex; justify-content: space-between; align-items: center; margin-top: 10px; border-top: 1px solid #f0f0f0; padding-top: 10px; }
.price-value { font-size: 1.3rem; font-weight: 800; color: #333; }

.bg-white-section { background: white; padding: 2rem; border-radius: 16px; box-shadow: 0 2px 10px rgba(0,0,0,0.02); }
.horizontal-card { min-width: 320px; display: flex; align-items: center; }
.h-icon-side { width: 90px; height: 100px; background: #FCE4EC; color: #E91E63; display: flex; align-items: center; justify-content: center; font-size: 2rem; }
.h-info-side { padding: 1rem; flex: 1; }
.h-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
.sales-badge { font-size: 0.8rem; color: #ff9800; }
.h-price { font-weight: bold; color: #333; font-size: 1.1rem; }

.cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
.service-card .service-img-mock { height: 140px; background-color: #cfd8dc; display: flex; align-items: center; justify-content: center; color: white; font-size: 2rem; }
.category-pill { display: inline-block; background: #E0F2F1; color: #009688; font-size: 0.75rem; padding: 3px 8px; border-radius: 4px; margin-bottom: 8px; font-weight: 600; }
.card-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 15px; }
.btn-icon-only { width: 35px; height: 35px; border-radius: 50%; background: #f5f5f5; border: none; color: #333; cursor: pointer; transition: 0.2s; }
.btn-icon-only:hover { background: #E91E63; color: white; }

.no-results { text-align: center; padding: 3rem; color: #999; font-size: 1.2rem; }
.no-results i { font-size: 3rem; margin-bottom: 1rem; display: block; }

/* --- ESTILOS DEL MODAL --- */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  backdrop-filter: blur(4px);
}

.modal-content {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  width: 90%;
  max-width: 400px;
  text-align: center;
  box-shadow: 0 10px 25px rgba(0,0,0,0.2);
  animation: modalPop 0.3s ease-out;
}

.modal-icon { font-size: 3rem; color: #E91E63; margin-bottom: 1rem; }
.modal-content h3 { margin: 0 0 0.5rem 0; color: #333; }
.modal-content p { color: #666; margin-bottom: 2rem; line-height: 1.5; }

.modal-actions { display: flex; gap: 10px; justify-content: center; }
.modal-actions .btn { flex: 1; }

@keyframes modalPop {
    from { opacity: 0; transform: scale(0.9); }
    to { opacity: 1; transform: scale(1); }
}
</style>