<template>
  <div class="tickets-container">
    
    <div v-if="loading" class="loading-state">
      <i class="fa-solid fa-circle-notch fa-spin"></i> Cargando tus servicios...
    </div>

    <div v-else-if="tickets.length === 0" class="empty-state">
      <i class="fa-solid fa-ticket-simple"></i>
      <h3>Aún no tienes servicios activos</h3>
      <p>Cuando realices una compra, tus boletos aparecerán aquí.</p>
    </div>

    <div v-else class="tickets-list">
      <div v-for="ticket in tickets" :key="ticket.ticket_id" class="ticket-card">
        
        <div class="ticket-info">
          <div class="ticket-header">
            <span class="ticket-type" :class="getTypeClass(ticket.tipo)">
              <i :class="getIcon(ticket.tipo)"></i> {{ ticket.tipo }}
            </span>
            <span class="ticket-id">#{{ ticket.ticket_id }}</span>
          </div>

          <h3 class="service-title">{{ ticket.titulo }}</h3>
          <p class="service-subtitle">{{ ticket.subtitulo }}</p>

          <div class="ticket-details">
            <div class="detail-row">
              <i class="fa-regular fa-calendar"></i>
              <span>{{ formatDate(ticket.fecha_inicio) }}</span>
              <i class="fa-solid fa-arrow-right-long" v-if="ticket.fecha_fin"></i>
              <span v-if="ticket.fecha_fin">{{ formatDate(ticket.fecha_fin) }}</span>
            </div>
            
            <div class="detail-row">
              <i class="fa-solid fa-location-dot"></i>
              <span>{{ ticket.ubicacion }}</span>
            </div>

            <div class="detail-row highlight">
              <i class="fa-solid fa-circle-info"></i>
              <span>{{ ticket.detalle_extra }}</span>
            </div>

            <div class="traveler-badge">
              <i class="fa-solid fa-user"></i> {{ ticket.viajero_nombre }}
            </div>
          </div>
        </div>

        <div class="ticket-qr">
          <img :src="`https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${ticket.qr_data}`" alt="QR Code">
          <small>Escanea en recepción</small>
        </div>

      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const props = defineProps(['userId']); // Recibimos el ID del usuario
const tickets = ref([]);
const loading = ref(true);

const fetchTickets = async () => {
  loading.value = true;
  try {
    const res = await fetch('http://localhost:3000/api/users/my-tickets', { // Ajusta tu ruta
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({ user_id: props.userId })
    });
    const data = await res.json();
    if(data.success) {
      tickets.value = data.data;
    }
  } catch(e) {
    console.error(e);
  } finally {
    loading.value = false;
  }
};

// Helpers visuales
const formatDate = (dateString) => {
  if(!dateString) return '';
  const d = new Date(dateString);
  return d.toLocaleDateString('es-VE', { day: 'numeric', month: 'short', hour: '2-digit', minute:'2-digit' });
};

const getIcon = (tipo) => {
  const map = { 'Traslado': 'fa-plane', 'Servicio': 'fa-ticket', 'Alojamiento': 'fa-bed', 'Restaurante': 'fa-utensils' };
  return `fa-solid ${map[tipo] || 'fa-star'}`;
};

const getTypeClass = (tipo) => {
  const map = { 'Traslado': 'type-blue', 'Servicio': 'type-green', 'Alojamiento': 'type-purple', 'Restaurante': 'type-orange' };
  return map[tipo] || 'type-gray';
};

onMounted(() => {
  if(props.userId) fetchTickets();
});
</script>

<style scoped>
.tickets-container { padding: 10px; }

.loading-state, .empty-state {
  text-align: center; padding: 40px; color: #9ca3af;
}
.empty-state i { font-size: 3rem; margin-bottom: 10px; }

.tickets-list { display: flex; flex-direction: column; gap: 20px; }

/* Tarjeta Ticket */
.ticket-card {
  background: white;
  border-radius: 16px;
  display: flex;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
  transition: transform 0.2s;
}
.ticket-card:hover { transform: translateY(-3px); box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); }

/* Sección Info (Izquierda) */
.ticket-info { flex: 1; padding: 20px; border-right: 2px dashed #e5e7eb; position: relative; }

/* Efecto de "muesca" del ticket */
.ticket-info::after {
  content: ''; position: absolute; right: -10px; top: 50%; transform: translateY(-50%);
  width: 20px; height: 20px; background-color: #f3f4f6; border-radius: 50%;
}

.ticket-header { display: flex; justify-content: space-between; margin-bottom: 10px; }
.ticket-id { font-family: monospace; color: #9ca3af; font-size: 0.9rem; }

.ticket-type { padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
.type-blue { background: #eff6ff; color: #3b82f6; }
.type-green { background: #f0fdf4; color: #22c55e; }
.type-purple { background: #faf5ff; color: #a855f7; }
.type-orange { background: #fff7ed; color: #f97316; }

.service-title { margin: 5px 0; font-size: 1.2rem; color: #1f2937; }
.service-subtitle { margin: 0 0 15px 0; color: #6b7280; font-size: 0.95rem; }

.ticket-details { display: flex; flex-direction: column; gap: 8px; }
.detail-row { display: flex; align-items: center; gap: 10px; color: #4b5563; font-size: 0.9rem; }
.detail-row.highlight { color: #db2777; font-weight: 600; }

.traveler-badge {
  margin-top: 10px; display: inline-block; background: #f3f4f6; padding: 5px 10px;
  border-radius: 6px; font-size: 0.85rem; color: #374151; font-weight: 600;
}

/* Sección QR (Derecha) */
.ticket-qr {
  width: 180px; display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 20px; background-color: #fafafa;
}
.ticket-qr img { width: 120px; height: 120px; mix-blend-mode: multiply; }
.ticket-qr small { margin-top: 10px; color: #9ca3af; font-size: 0.75rem; text-align: center; }

@media (max-width: 640px) {
  .ticket-card { flex-direction: column; }
  .ticket-info { border-right: none; border-bottom: 2px dashed #e5e7eb; }
  .ticket-qr { width: 100%; padding: 15px; }
}
</style>