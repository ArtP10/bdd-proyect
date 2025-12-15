<template>
  <div class="dashboard-layout">
    <aside class="sidebar">
      <div class="sidebar-header">
        <h1>Admin Panel</h1>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li :class="{ active: activeMenu === 'Resumen' }">
            <a href="#" @click.prevent="activeMenu = 'Resumen'">Resumen</a>
          </li>
          <li :class="{ active: activeMenu === 'Reportes' }">
            <a href="#" @click.prevent="activeMenu = 'Reportes'">Reportes</a>
          </li>
          <li :class="{ active: activeMenu === 'Proveedores' }">
            <a href="#" @click.prevent="activeMenu = 'Proveedores'">Proveedores</a>
          </li>
          <li :class="{ active: activeMenu === 'Promociones' }">
            <a href="#" @click.prevent="activeMenu = 'Promociones'">Promociones</a>
          </li>
          <li :class="{ active: activeMenu === 'Roles' }">
            <a href="#" @click.prevent="activeMenu = 'Roles'">Roles</a>
          </li>
          <li :class="{ active: activeMenu === 'Paquetes' }">
            <a href="#" @click.prevent="activeMenu = 'Paquetes'">Paquetes Turísticos</a>
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
      <h2 class="page-title">{{ activeMenu }}</h2>

      <div v-if="activeMenu === 'Resumen'">
        <p>Bienvenido al panel de administración.</p>
      </div>
      
      <div v-if="activeMenu === 'Reportes'">
        <AdminReportes />
      </div>

      <div v-if="activeMenu === 'Proveedores'">
        <AdminGestionProveedor />
      </div>
      <div v-if="activeMenu === 'Promociones'">
        <Promotions />
      </div>

      <div v-if="activeMenu === 'Roles'">
        <Roles />
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

// Importamos tus componentes
import AdminGestionProveedor from './AdminGestionProveedor.vue';
import Roles from './Roles.vue';
import Promotions from './AdminGestionPromociones.vue';
import AdminGestionPaquetes from './AdminGestionPaquetes.vue';
import AdminReportes from './AdminReports.vue'; // <--- IMPORTADO

const router = useRouter();
const activeMenu = ref('Reportes'); // Lo puse activo por defecto para que lo veas al entrar

onMounted(() => {
  const session = localStorage.getItem('user_session');
  if (!session) router.push('/login');
});

const handleLogout = () => {
    localStorage.removeItem('user_session');
    localStorage.removeItem('userRole');
    router.push('/');
};
</script>

<style scoped>
/* Tus estilos existentes se mantienen igual */
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }
.sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; } 
.sidebar-header { padding: 1.5rem; background-color: #0f172a; }
.sidebar-nav ul { list-style: none; padding: 0; }
.sidebar-nav li a { display: block; padding: 1rem 1.5rem; color: #cbd5e1; text-decoration: none; border-left: 4px solid transparent; transition: all 0.3s ease; }
/* Un pequeño detalle visual: borde azul al estar activo */
.sidebar-nav li.active a { background-color: #334155; color: white; border-left-color: #3b82f6; }
.sidebar-nav li a:hover { background-color: #334155; } /* Efecto hover añadido */
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.page-title { margin-bottom: 2rem; font-weight: 600; color: #1e293b; }
.sidebar-footer { padding: 1.5rem; border-top: 1px solid #f0f0f0; margin-top: auto; }
.btn-logout { background: none; border: none; color: #cbd5e1; cursor: pointer; font-size: 1rem; width: 100%; text-align: left; }
.btn-logout:hover { color: white; }
</style>