<template>
  <div class="dashboard-layout">
    
    <aside class="sidebar">
      <div class="sidebar-header">
        <h1>Viajero 360°</h1>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li v-for="item in menuItems" :key="item" :class="{ active: item === activeMenuItem }">
            <a href="#" @click.prevent="activeMenuItem = item">
              <span v-if="item !== activeMenuItem" class="dot"></span>
              <span v-else class="dot-white"></span>
              {{ item }}
            </a>
          </li>
        </ul>
      </nav>

      <div class="sidebar-footer">
        <button class="btn-logout" @click="handleLogout">
          <i class="fa-solid fa-right-from-bracket"></i> Cerrar Sesión
        </button>
      </div>
    </aside>

    <main class="main-content">
      <header class="content-header">
        <h2 class="page-title">{{ activeMenuItem }}</h2>
        
        <div class="header-right">
            <div class="miles-badge">
                <i class="fa-solid fa-plane-departure"></i> 
                <span>{{ currentMiles }} Millas</span>
            </div>
            
            <button class="btn-shop" @click="goToStore">
                <i class="fa-solid fa-store"></i> Ver Tienda
            </button>
        </div>
      </header>

      <div class="tabs-container" v-if="activeMenuItem === 'Pagos'">
        <Payments :user-id="userInfo.user_id" />
      </div>

      <div class="tabs-container" v-if="activeMenuItem === 'Gestion'">
         <div class="tabs">
             <button class="tab" :class="{ active: activeTab === 'Datos personales' }" @click="activeTab = 'Datos personales'">Datos personales</button>
             <button class="tab" :class="{ active: activeTab === 'Mis viajeros' }" @click="activeTab = 'Mis viajeros'">Mis viajeros</button> 
             <button class="tab" :class="{ active: activeTab === 'Seguridad' }" @click="activeTab = 'Seguridad'">Seguridad</button>
         </div>
      </div>

      <div class="content-body">
          
          <div v-if="activeMenuItem === 'Resumen'" class="dashboard-summary">
              
              <div class="stats-card miles-card">
                  <div class="card-icon">
                      <i class="fa-solid fa-award"></i>
                  </div>
                  <div class="card-info">
                      <h3>Mis Millas Acumuladas</h3>
                      <div class="big-number">{{ currentMiles }}</div>
                      <p>Nivel: Viajero Explorador</p>
                  </div>
                  <div class="card-action">
                      <button class="btn-sm-outline" @click="activeMenuItem = 'Millas'">Ver Historial</button>
                  </div>
              </div>

              <div class="stats-card welcome-card">
                  <h3>¡Hola, {{ userInfo.user_name }}!</h3>
                  <p>Tienes nuevas aventuras esperando por ti. Revisa tu itinerario o explora nuevos destinos.</p>
              </div>
          </div>

          <div v-else-if="activeMenuItem === 'Gestion'">
              <div v-if="activeTab === 'Datos personales'" class="profile-card">
                  <h3>Información de Cuenta</h3>
                  <p><strong>Usuario:</strong> {{ userInfo.user_name }}</p>
                  <p><strong>Email:</strong> {{ userInfo.user_email }}</p>
              </div>
              <div v-if="activeTab === 'Mis viajeros'">
                  <Travelers />
              </div>
              <div v-if="activeTab === 'Seguridad'" class="profile-card">
                  <p>Configuración de contraseña y seguridad...</p>
              </div>
          </div>

          <div v-else-if="activeMenuItem === 'Mis Servicios'">
             <MyServices :user-id="userInfo.user_id" />
          </div>

          <div v-else class="profile-card empty-section">
             <i class="fa-solid fa-helmet-safety"></i>
             <p>La sección <strong>{{ activeMenuItem }}</strong> está en construcción.</p>
          </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
// Asegúrate que estos archivos existen en la misma carpeta, o comenta los imports si aún no los tienes
import Travelers from './Travelers.vue'; 
import MyServices from './MyServices.vue';
import Payments from './Payments.vue';

const router = useRouter();
const userInfo = ref({});
const currentMiles = ref(0); 
const activeMenuItem = ref('Resumen'); 
const activeTab = ref('Datos personales'); 

const menuItems = [
  'Resumen', 'Mis Servicios', 'Pagos', 'Millas', 
  'Deseos', 'Sostenibilidad', 'Notificaciones', 
  'Reclamos', 'Gestion', 'Cancelaciones'
];

onMounted(() => {
  const session = localStorage.getItem('user_session');
  if (session) {
    try {
        userInfo.value = JSON.parse(session);
        // Llamada segura para obtener millas
        if (userInfo.value.user_id) {
            fetchUpdatedMiles(userInfo.value.user_id);
        }
    } catch (e) {
        console.error("Error leyendo sesión", e);
        router.push('/login');
    }
  } else {
    router.push('/login');
  }
});

const fetchUpdatedMiles = async (userId) => {
    try {
        const res = await fetch(`http://localhost:3000/api/users/miles/${userId}`);
        const data = await res.json();
        if(data.success) {
            currentMiles.value = data.miles;
        }
    } catch(e) {
        console.error("No se pudieron cargar las millas", e);
    }
};

const goToStore = () => {
    router.push('/home');
};

const handleLogout = () => {
    localStorage.removeItem('user_session');
    localStorage.removeItem('userRole');
    router.push('/');
};
</script>

<style scoped>
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }

/* Sidebar */
.sidebar { width: 250px; background-color: white; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; }
.sidebar-header { padding: 1.5rem; border-bottom: 1px solid #f0f0f0; }
.sidebar-header h1 { font-size: 1.25rem; font-weight: 700; color: #374151; margin: 0; }
.sidebar-nav { flex: 1; overflow-y: auto; }
.sidebar-nav ul { list-style: none; padding: 0; margin: 1rem 0; }
.sidebar-nav li a { display: flex; align-items: center; padding: 0.75rem 1.5rem; text-decoration: none; color: #4b5563; font-weight: 500; transition: background 0.2s; }
.sidebar-nav li:hover a { background-color: #f9fafb; color: #e91e63; }
.dot { width: 8px; height: 8px; background-color: #9ca3af; border-radius: 50%; margin-right: 12px; }
.sidebar-nav li:hover .dot { background-color: #e91e63; }
.sidebar-nav li.active a { background: linear-gradient(90deg, #ec4899, #3b82f6); color: white; }
.sidebar-nav li.active .dot { background-color: white; }
.dot-white { width: 8px; height: 8px; background-color: white; border-radius: 50%; margin-right: 12px; }

.sidebar-footer { padding: 1.5rem; border-top: 1px solid #f0f0f0; }
.btn-logout { width: 100%; padding: 0.8rem; background: transparent; border: 1px solid #ef4444; color: #ef4444; border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; justify-content: center; gap: 8px; }
.btn-logout:hover { background-color: #ef4444; color: white; }

/* Main Content */
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.content-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.header-right { display: flex; align-items: center; gap: 15px; }
.page-title { font-size: 1.5rem; font-weight: 700; color: #111827; margin: 0; }

/* Badge de Millas en Header */
.miles-badge { background: white; padding: 0.5rem 1rem; border-radius: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); display: flex; align-items: center; gap: 8px; color: #e91e63; font-weight: 700; font-size: 0.9rem; }

.btn-shop { background: linear-gradient(135deg, #00BCD4 0%, #0097a7 100%); color: white; border: none; padding: 0.8rem 1.5rem; border-radius: 50px; font-weight: 700; font-size: 1rem; cursor: pointer; box-shadow: 0 4px 15px rgba(0, 188, 212, 0.4); display: flex; align-items: center; gap: 8px; }
.btn-shop:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0, 188, 212, 0.6); }

/* Tabs Container */
.tabs-container { margin-bottom: 1.5rem; }
.tabs { display: flex; gap: 1rem; border-bottom: 1px solid #e5e7eb; }
.tab { padding: 0.75rem 1.5rem; background: none; border: none; font-weight: 600; color: #6b7280; cursor: pointer; border-bottom: 2px solid transparent; }
.tab.active { background-color: #db2777; color: white; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: none; }

/* Dashboard Summary Cards */
.dashboard-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
.stats-card { background: white; padding: 25px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.03); display: flex; flex-direction: column; justify-content: center; }

/* Tarjeta Millas Especifica */
.miles-card { background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%); color: white; position: relative; overflow: hidden; }
.miles-card .card-icon { font-size: 3rem; opacity: 0.2; position: absolute; top: 20px; right: 20px; }
.miles-card h3 { margin: 0; font-size: 1rem; opacity: 0.8; font-weight: 400; }
.big-number { font-size: 3rem; font-weight: 800; margin: 10px 0; color: #38bdf8; }
.btn-sm-outline { background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.3); color: white; padding: 5px 12px; border-radius: 4px; cursor: pointer; font-size: 0.8rem; margin-top: 10px; width: fit-content; }
.btn-sm-outline:hover { background: rgba(255,255,255,0.2); }

.welcome-card { border-left: 5px solid #e91e63; }
.profile-card { background: white; border-radius: 12px; padding: 2rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.empty-section { text-align: center; color: #9ca3af; padding: 3rem; }
.empty-section i { font-size: 3rem; margin-bottom: 1rem; }

@media (max-width: 768px) {
  .dashboard-layout { flex-direction: column; }
  .sidebar { width: 100%; height: auto; }
  .content-header { flex-direction: column; gap: 1rem; align-items: flex-start; }
  .header-right { width: 100%; justify-content: space-between; }
}
</style>