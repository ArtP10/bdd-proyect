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
    </aside>

    <main class="main-content">
      <h2 class="page-title">{{ activeMenuItem }}</h2>

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
        <div class="profile-card">
          <p>Contenido de {{ activeMenuItem }} en construcción...</p>
        </div>
      </div>

    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
// IMPORTANTE: Importar el componente hijo
import Travelers from './Travelers.vue'; 

const router = useRouter();
const userInfo = ref({});

// IMPORTANTE: Definir las variables reactivas
const activeMenuItem = ref('Resumen'); // Pestaña inicial del sidebar
const activeTab = ref('Datos personales'); // Pestaña inicial dentro de Gestión

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
</script>

<style scoped>
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }

/* Sidebar */
.sidebar { width: 250px; background-color: white; border-right: 1px solid #e5e7eb; display: flex; flex-direction: column; }
.sidebar-header { padding: 1.5rem; border-bottom: 1px solid #f0f0f0; }
.sidebar-header h1 { font-size: 1.25rem; font-weight: 700; color: #374151; margin: 0; }
.sidebar-nav ul { list-style: none; padding: 0; margin: 1rem 0; }
.sidebar-nav li a { display: flex; align-items: center; padding: 0.75rem 1.5rem; text-decoration: none; color: #4b5563; font-weight: 500; transition: background 0.2s; }
.sidebar-nav li:hover a { background-color: #f9fafb; color: #e91e63; }
.dot { width: 8px; height: 8px; background-color: #9ca3af; border-radius: 50%; margin-right: 12px; }
.sidebar-nav li:hover .dot { background-color: #e91e63; }

/* Active Item Style (Gradient) */
.sidebar-nav li.active a { background: linear-gradient(90deg, #ec4899, #3b82f6); color: white; }
.sidebar-nav li.active .dot { background-color: white; } /* Corrección visual para el punto */
.dot-white { width: 8px; height: 8px; background-color: white; border-radius: 50%; margin-right: 12px; }

/* Main Content */
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.page-title { font-size: 1.5rem; font-weight: 700; color: #111827; margin-bottom: 1.5rem; }

/* Tabs */
.tabs { display: flex; gap: 1rem; border-bottom: 1px solid #e5e7eb; margin-bottom: 1.5rem; }
.tab { padding: 0.75rem 1.5rem; background: none; border: none; font-weight: 600; color: #6b7280; cursor: pointer; border-bottom: 2px solid transparent; }
.tab:hover { color: #374151; }
.tab.active { background-color: #db2777; color: white; border-top-left-radius: 8px; border-top-right-radius: 8px; border-bottom: none; }

/* Profile Card */
.profile-card { background: white; border-radius: 12px; padding: 2rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); max-width: 900px; }
.profile-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; }
.profile-item label { display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: #6b7280; margin-bottom: 0.25rem; }
.value { font-size: 1.1rem; font-weight: 600; color: #111827; margin: 0; }
.full-width { grid-column: 1 / -1; border-top: 1px solid #f3f4f6; padding-top: 1rem; }
.card-footer { margin-top: 2rem; color: #9ca3af; font-size: 0.85rem; font-style: italic; }

@media (max-width: 768px) {
  .dashboard-layout { flex-direction: column; }
  .sidebar { width: 100%; height: auto; }
  .profile-grid { grid-template-columns: 1fr; }
}
</style>