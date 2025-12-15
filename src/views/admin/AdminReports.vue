<template>
  <div class="admin-reportes">
    <h2>Generación de Reportes</h2>
    <p class="description">Selecciona el reporte que deseas descargar en formato PDF.</p>

    <div class="report-grid">
      
      <div class="report-card">
        <div class="icon-container"><i class="fa-solid fa-box-open"></i></div>
        <h3>Paquetes Turísticos</h3>
        <p>Listado completo de paquetes y destinos.</p>
        <button @click="descargarReporte('paquetes')" class="btn-download" :disabled="loading">
          <span v-if="!loading">Descargar PDF</span>
          <span v-else>Generando...</span>
        </button>
      </div>

      <div class="report-card">
        <div class="icon-container"><i class="fa-solid fa-medal"></i></div>
        <h3>Top 5 Canjes por Millas</h3>
        <p>Los paquetes más populares pagados con millas.</p>
        <button @click="descargarReporte('top-millas')" class="btn-download" :disabled="loading">
          <span v-if="!loading">Descargar PDF</span>
          <span v-else>Generando...</span>
        </button>
      </div>

      <div class="report-card">
        <div class="icon-container"><i class="fa-solid fa-scale-balanced"></i></div>
        <h3>Auditoría de Reembolsos</h3>
        <p>Verificación de penalizaciones (10%) y devoluciones.</p>
        <button @click="descargarReporte('auditoria-reembolsos')" class="btn-download" :disabled="loading">
          <span v-if="!loading">Descargar PDF</span>
          <span v-else>Generando...</span>
        </button>
      </div>

      <div class="report-card">
        <div class="icon-container"><i class="fa-solid fa-chart-pie"></i></div>
        <h3>Preferencias vs Realidad</h3>
        <p>Comparativa entre lo declarado y lo comprado.</p>
        <button @click="descargarReporte('preferencias-vs-realidad')" class="btn-download" :disabled="loading">
          <span v-if="!loading">Descargar PDF</span>
          <span v-else>Generando...</span>
        </button>
      </div>

      <div class="report-card">
        <div class="icon-container"><i class="fa-solid fa-users-viewfinder"></i></div>
        <h3>Top Clientes (Millas)</h3>
        <p>Clientes con mayor saldo de millas sin canjear.</p>
        <button @click="descargarReporte('clientes-millas')" class="btn-download" :disabled="loading">
          <span v-if="!loading">Descargar PDF</span>
          <span v-else>Generando...</span>
        </button>
      </div>

      </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';

const loading = ref(false);

const descargarReporte = async (tipo) => {
  loading.value = true;
  try {
    // Usamos '/api/report/' (SINGULAR)
    const response = await axios.get(`http://localhost:3000/api/report/${tipo}`, {
      responseType: 'blob'
    });

    const url = window.URL.createObjectURL(new Blob([response.data]));
    const link = document.createElement('a');
    link.href = url;
    link.setAttribute('download', `reporte-${tipo}.pdf`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);

  } catch (error) {
    console.error("Error al descargar:", error);
    alert("Hubo un error al generar el reporte.");
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.admin-reportes { padding: 20px; }
.description { margin-bottom: 30px; color: #64748b; }

/* --- AQUÍ ESTÁ LA MAGIA DEL CATÁLOGO (2 COLUMNAS) --- */
.report-grid { 
    display: grid; 
    /* Forzamos exactamente 2 columnas del mismo tamaño */
    grid-template-columns: repeat(2, 1fr); 
    gap: 25px; /* Un poco más de espacio entre tarjetas */
    max-width: 1000px; /* Opcional: para que no se estiren demasiado en pantallas gigantes */
    margin: 0 auto; /* Centrar el grid */
}

.report-card { 
    background: white; 
    padding: 25px; /* Un poco más de padding */
    border-radius: 12px; 
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1); 
    text-align: center; 
    transition: transform 0.2s, box-shadow 0.2s;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.report-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.icon-container { font-size: 2.5rem; color: #3b82f6; margin-bottom: 15px; }

.report-card h3 { 
    margin: 10px 0; 
    color: #1e293b; 
    font-size: 1.2rem;
}

.report-card p { 
    color: #64748b; 
    font-size: 0.95rem; 
    margin-bottom: 20px;
    flex-grow: 1; /* Esto hace que el botón siempre quede abajo alineado */
}

.btn-download { 
    background-color: #3b82f6; 
    color: white; 
    border: none; 
    padding: 12px 20px; 
    border-radius: 8px; 
    cursor: pointer; 
    width: 100%; 
    font-weight: 600;
    transition: background-color 0.3s;
}

.btn-download:hover { background-color: #2563eb; }
.btn-download:disabled { background-color: #94a3b8; cursor: not-allowed; }
</style>