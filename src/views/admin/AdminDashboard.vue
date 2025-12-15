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
          <li :class="{ active: activeMenu === 'Proveedores' }">
            <a href="#" @click.prevent="activeMenu = 'Proveedores'">Proveedores</a>
          </li>
          <li :class="{ active: activeMenu === 'Promociones' }">
            <a href="#" @click.prevent="activeMenu = 'Promociones'">Promociones</a>
          </li>
          <li :class="{ active: activeMenu === 'Roles' }">
            <a href="#" @click.prevent="activeMenu = 'Roles'">Roles</a>
          </li>
        </ul>
      </nav>
    </aside>

    <main class="main-content">
      <h2 class="page-title">{{ activeMenu }}</h2>

      <div v-if="activeMenu === 'Resumen'">
        <p>Bienvenido al panel de administración.</p>
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
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import AdminGestionProveedor from './AdminGestionProveedor.vue';
import Promotions from './Promotions.vue';
import Roles from './Roles.vue';

const router = useRouter();
const activeMenu = ref('Proveedores'); // Por defecto para probar

onMounted(() => {
  const session = localStorage.getItem('user_session');
  if (!session) router.push('/login');
  // Aquí podrías validar si el rol es realmente Administrador
});
</script>

<style scoped>
/* Reutiliza los estilos del ClientDashboard (sidebar, main-content, etc) */
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }
.sidebar { width: 250px; background-color: #1e293b; color: white; display: flex; flex-direction: column; } /* Dark sidebar para admin */
.sidebar-header { padding: 1.5rem; background-color: #0f172a; }
.sidebar-nav ul { list-style: none; padding: 0; }
.sidebar-nav li a { display: block; padding: 1rem 1.5rem; color: #cbd5e1; text-decoration: none; }
.sidebar-nav li.active a { background-color: #3b82f6; color: white; }
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
</style>