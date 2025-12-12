<template>
  <div class="dashboard-layout">
    <aside class="sidebar">
      <div class="sidebar-header">
        <h1>Panel Aerolínea</h1>
      </div>
      <nav class="sidebar-nav">
        <ul>
          <li :class="{ active: activeMenu === 'Resumen' }">
            <a href="#" @click.prevent="activeMenu = 'Resumen'">Resumen</a>
          </li>
          <li :class="{ active: activeMenu === 'Flota' }">
            <a href="#" @click.prevent="activeMenu = 'Flota'">Flota</a>
          </li>
          <li :class="{ active: activeMenu === 'Rutas' }">
            <a href="#" @click.prevent="activeMenu = 'Rutas'">Rutas</a>
          </li>
          <li :class="{ active: activeMenu === 'Vuelos' }">
            <a href="#" @click.prevent="activeMenu = 'Vuelos'">Vuelos (Traslados)</a>
          </li>
        </ul>
      </nav>
    </aside>

    <main class="main-content">
      <h2 class="page-title">{{ activeMenu }}</h2>

      <div v-if="activeMenu === 'Resumen'">
        <p>Bienvenido al panel de gestión de aerolínea.</p>
      </div>

      <div v-if="activeMenu === 'Flota'">
        <Fleet />
      </div>

      <div v-if="activeMenu === 'Rutas'">
        <AirlineRoutes />
      </div>
      <div v-if="activeMenu === 'Vuelos'">
    <AirlineTravels />
</div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import Fleet from './Fleet.vue'; // Importamos el componente hijo
import AirlineRoutes from './AirlineRoutes.vue';
import AirlineTravels from './AirlineTravels.vue';

const router = useRouter();
const activeMenu = ref('Flota'); // Por defecto para probar

onMounted(() => {
  const session = localStorage.getItem('user_session');
  if (!session) router.push('/login');
});
</script>

<style scoped>
/* Estilos consistentes con los dashboards anteriores */
.dashboard-layout { display: flex; height: 100vh; background-color: #f3f4f6; font-family: 'Segoe UI', sans-serif; }
.sidebar { width: 250px; background-color: #0f172a; color: white; display: flex; flex-direction: column; }
.sidebar-header { padding: 1.5rem; background-color: #020617; border-bottom: 1px solid #1e293b; }
.sidebar-nav ul { list-style: none; padding: 0; }
.sidebar-nav li a { display: block; padding: 1rem 1.5rem; color: #94a3b8; text-decoration: none; transition: 0.2s; }
.sidebar-nav li a:hover { color: white; background: #1e293b; }
.sidebar-nav li.active a { background-color: #3b82f6; color: white; border-right: 4px solid #60a5fa; }
.main-content { flex: 1; padding: 2rem; overflow-y: auto; }
.page-title { font-size: 1.8rem; font-weight: 700; color: #1e293b; margin-bottom: 1.5rem; }
</style>