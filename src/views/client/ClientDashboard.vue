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
        <button class="btn-shop" @click="goToStore">
          <i class="fa-solid fa-store"></i> Ver Tienda
        </button>
      </header>

      <div class="tabs" v-if="activeMenuItem === 'Pagos'">
        <Payments :user-id="userInfo.user_id" />
      </div>

      <div class="tabs" v-if="activeMenuItem === 'Gestion'">
         <button class="tab" :class="{ active: activeTab === 'Datos personales' }" @click="activeTab = 'Datos personales'">Datos personales</button>
         <button class="tab" :class="{ active: activeTab === 'Mis viajeros' }" @click="activeTab = 'Mis viajeros'">Mis viajeros</button> 
         <button class="tab" :class="{ active: activeTab === 'Seguridad' }" @click="activeTab = 'Seguridad'">Seguridad</button>
      </div>

      <div v-if="activeMenuItem === 'Gestion'">
          <div v-if="activeTab === 'Datos personales'" class="profile-card">
              <h3>Bienvenido, {{ userInfo.user_name }}</h3>
              <p>Aquí irían tus datos personales...</p>
          </div>
          <div v-if="activeTab === 'Mis viajeros'">
              <Travelers />
          </div>
          <div v-if="activeTab === 'Seguridad'" class="profile-card">
              <p>Configuración de seguridad...</p>
          </div>
      </div>

      <div v-else>
   <div v-if="activeMenuItem === 'Mis Servicios'">
      <MyServices :user-id="userInfo.user_id" />
   </div>

   <div v-else class="profile-card">
      <p>Contenido de {{ activeMenuItem }} en construcción...</p>
   </div>
</div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Travelers from './Travelers.vue'; 
import MyServices from './MyServices.vue';
import Payments from './Payments.vue';

const router = useRouter();
const userInfo = ref({});
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
    userInfo.value = JSON.parse(session);
  } else {
    router.push('/login');
  }
});

// NUEVAS FUNCIONES
const goToStore = () => {
    router.push('/');
};

const handleLogout = () => {
    localStorage.removeItem('user_session');
    localStorage.removeItem('userRole');
    router.push('/login');
};
</script>

<style scoped>
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }

/* Sidebar */
.sidebar { width: 250px; background-color: white; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; }
.sidebar-header { padding: 1.5rem; border-bottom: 1px solid #f0f0f0; }
.sidebar-header h1 { font-size: 1.25rem; font-weight: 700; color: #374151; margin: 0; }
.sidebar-nav { flex: 1; overflow-y: auto; } /* Para que el footer baje */
.sidebar-nav ul { list-style: none; padding: 0; margin: 1rem 0; }
.sidebar-nav li a { display: flex; align-items: center; padding: 0.75rem 1.5rem; text-decoration: none; color: #4b5563; font-weight: 500; transition: background 0.2s; }
.sidebar-nav li:hover a { background-color: #f9fafb; color: #e91e63; }
.dot { width: 8px; height: 8px; background-color: #9ca3af; border-radius: 50%; margin-right: 12px; }
.sidebar-nav li:hover .dot { background-color: #e91e63; }
.sidebar-nav li.active a { background: linear-gradient(90deg, #ec4899, #3b82f6); color: white; }
.sidebar-nav li.active .dot { background-color: white; }
.dot-white { width: 8px; height: 8px; background-color: white; border-radius: 50%; margin-right: 12px; }

/* Sidebar Footer (Logout) */
.sidebar-footer { padding: 1.5rem; border-top: 1px solid #f0f0f0; }
.btn-logout {
    width: 100%;
    padding: 0.8rem;
    background: transparent;
    border: 1px solid #ef4444;
    color: #ef4444;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}
.btn-logout:hover { background-color: #ef4444; color: white; }

/* Main Content */
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }

/* Content Header (Título + Botón Tienda) */
.content-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
}
.page-title { font-size: 1.5rem; font-weight: 700; color: #111827; margin: 0; }

/* Botón Ver Tienda (Llamativo) */
.btn-shop {
    background: linear-gradient(135deg, #00BCD4 0%, #0097a7 100%);
    color: white;
    border: none;
    padding: 0.8rem 1.5rem;
    border-radius: 50px; /* Redondo estilo píldora */
    font-weight: 700;
    font-size: 1rem;
    cursor: pointer;
    box-shadow: 0 4px 15px rgba(0, 188, 212, 0.4);
    transition: transform 0.2s, box-shadow 0.2s;
    display: flex;
    align-items: center;
    gap: 8px;
}
.btn-shop:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 188, 212, 0.6);
}

/* Tabs */
.tabs { display: flex; gap: 1rem; border-bottom: 1px solid #e5e7eb; margin-bottom: 1.5rem; }
.tab { padding: 0.75rem 1.5rem; background: none; border: none; font-weight: 600; color: #6b7280; cursor: pointer; border-bottom: 2px solid transparent; }
.tab:hover { color: #374151; }
.tab.active { background-color: #db2777; color: white; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: none; }

/* Profile Card */
.profile-card { background: white; border-radius: 12px; padding: 2rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); max-width: 900px; }

@media (max-width: 768px) {
  .dashboard-layout { flex-direction: column; }
  .sidebar { width: 100%; height: auto; }
  .content-header { flex-direction: column; gap: 1rem; align-items: flex-start; }
  .btn-shop { width: 100%; justify-content: center; }
}
</style>