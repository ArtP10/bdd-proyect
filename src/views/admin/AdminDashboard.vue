<template>
  <div class="dashboard-layout">
    <aside class="sidebar">
      <div class="sidebar-header">
        <h1>Admin Panel</h1>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li :class="{ active: activeMenu === 'Resumen' }">
            <a href="#" @click.prevent="activeMenu = 'Resumen'">
              <i class="fa-solid fa-chart-line"></i> Resumen
            </a>
          </li>
          
          <li :class="{ active: activeMenu === 'Roles' }">
            <a href="#" @click.prevent="activeMenu = 'Roles'">
              <i class="fa-solid fa-user-shield"></i> Roles
            </a>
          </li>

          <li :class="{ active: activeMenu === 'Proveedores' }">
            <a href="#" @click.prevent="activeMenu = 'Proveedores'">
              <i class="fa-solid fa-users"></i> Proveedores
            </a>
          </li>

          <li :class="{ active: activeMenu === 'Promociones' }">
            <a href="#" @click.prevent="activeMenu = 'Promociones'">
              <i class="fa-solid fa-tags"></i> Promociones
            </a>
          </li>

          <li :class="{ active: activeMenu === 'Paquetes' }">
            <a href="#" @click.prevent="activeMenu = 'Paquetes'">
              <i class="fa-solid fa-box-open"></i> Paquetes Turísticos
            </a>
          </li>
        </ul>
      </nav>
    </aside>

    <main class="main-content">
      <h2 class="page-title">{{ activeMenu }}</h2>

      <div v-if="activeMenu === 'Resumen'">
        <div class="welcome-card">
          <h3>👋 Bienvenido al Sistema</h3>
          <p>Selecciona una opción del menú lateral para comenzar a gestionar.</p>
        </div>
      </div>

      <div v-if="activeMenu === 'Roles'">
        <AdminGestionRoles />
      </div>

      <div v-if="activeMenu === 'Proveedores'">
        <AdminGestionProveedor />
      </div>

      <div v-if="activeMenu === 'Promociones'">
        <Promotions />
      </div>

      <div v-if="activeMenu === 'Paquetes'">
        <AdminGestionPaquetes />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';

// IMPORTS DE COMPONENTES
// Asegúrate de que los archivos existan en la carpeta views/admin
import AdminGestionProveedor from './AdminGestionProveedor.vue'; 
import Promotions from './AdminGestionPromociones.vue';
import AdminGestionPaquetes from './AdminGestionPaquetes.vue';
import AdminGestionRoles from './AdminGestionRoles.vue'; // <--- IMPORT NUEVO

const router = useRouter();
const activeMenu = ref('Paquetes'); 

onMounted(() => {
  const session = localStorage.getItem('user_session');
  // if (!session) router.push('/login'); // Descomentar para seguridad
});
</script>

<style scoped>
/* ESTILOS DEL DASHBOARD (Sin cambios) */
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }
.sidebar { width: 260px; background-color: #1e293b; color: white; display: flex; flex-direction: column; flex-shrink: 0; } 
.sidebar-header { padding: 1.5rem; background-color: #0f172a; text-align: center; border-bottom: 1px solid #334155; }
.sidebar-header h1 { margin: 0; font-size: 1.2rem; font-weight: 700; color: white; }
.sidebar-nav { flex: 1; overflow-y: auto; padding-top: 10px; }
.sidebar-nav ul { list-style: none; padding: 0; margin: 0; }
.sidebar-nav li a { 
    display: flex; align-items: center; gap: 10px; padding: 1rem 1.5rem; 
    color: #cbd5e1; text-decoration: none; border-left: 4px solid transparent; transition: all 0.2s;
}
.sidebar-nav li a:hover { background-color: #334155; color: white; }
.sidebar-nav li.active a { background-color: #334155; color: white; border-left-color: #3b82f6; }
.sidebar-nav i { width: 20px; text-align: center; }
.main-content { flex: 1; padding: 2rem; overflow-y: auto; background-color: #f8fafc; }
.page-title { margin-bottom: 1.5rem; font-size: 1.8rem; font-weight: 700; color: #1e293b; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; }
.welcome-card { background: white; padding: 40px; border-radius: 12px; text-align: center; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); color: #64748b; }
</style>