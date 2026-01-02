<template>
  <div class="services-container fade-in">
    
    <div class="header-section">
      <h2>Mis Servicios y Tickets</h2>
      <div class="tabs-nav">
        <button :class="{ active: activeTab === 'upcoming' }" @click="activeTab = 'upcoming'">
          <i class="fa-solid fa-ticket"></i> Próximos
        </button>
        <button :class="{ active: activeTab === 'history' }" @click="activeTab = 'history'">
          <i class="fa-solid fa-clock-rotate-left"></i> Historial
        </button>
      </div>
    </div>

    <div v-if="loading" class="loading-state">
        <i class="fa-solid fa-spinner fa-spin"></i> Cargando tickets...
    </div>

    <div v-else class="tickets-grid">
        
        <div v-if="filteredTickets.length === 0" class="empty-state">
            <i class="fa-solid fa-calendar-xmark"></i>
            <p>No hay tickets en esta sección.</p>
        </div>

        <div v-for="t in filteredTickets" :key="t.ticket_id" class="ticket-card" :class="t.tipo_clase">
            
            <div class="ticket-left">
                <span class="ticket-type">
                    {{ t.tipo }} 
                    <small v-if="t.estado === 'Cancelada'" class="cancelled-tag">CANCELADO</small>
                </span>
                
                <h3>{{ t.titulo }}</h3>
                <p class="subtitle">{{ t.subtitulo }}</p>
                
                <div class="ticket-extra" v-if="t.detalle_extra">
                    <i class="fa-solid fa-circle-info"></i> {{ t.detalle_extra }}
                </div>

                <div class="ticket-meta">
                    <div class="date-row">
                        <i class="fa-regular fa-calendar"></i> 
                        <span>{{ formatDate(t.fecha_inicio) }}</span>
                        <span v-if="t.fecha_fin && t.fecha_fin !== t.fecha_inicio" class="end-date">
                            <i class="fa-solid fa-arrow-right-long"></i> {{ formatDate(t.fecha_fin) }}
                        </span>
                    </div>
                    
                    <div v-if="t.ubicacion !== 'N/A'">
                        <i class="fa-solid fa-location-dot"></i> {{ t.ubicacion }}
                    </div>
                </div>
                
                <div class="passenger-info">
                    <i class="fa-solid fa-user"></i> {{ t.viajero_nombre }}
                </div>
            </div>

            <div class="ticket-right">
                <div class="qr-placeholder" @click="openScanner(t)">
                    <i class="fa-solid fa-qrcode"></i>
                    <span>Ver QR</span>
                </div>
                <div class="ticket-id">#{{ t.ticket_id }}</div>
                
                <button v-if="activeTab === 'upcoming'" class="btn-scan" @click="openScanner(t)">
                    <i class="fa-solid fa-expand"></i> Usar Ticket
                </button>
                <span v-else class="status-text">
                    {{ t.estado === 'Completada' ? 'USADO' : (t.estado === 'Cancelada' ? 'CANCELADO' : 'VENCIDO') }}
                </span>
            </div>
        </div>
    </div>

    <div v-if="showScanModal" class="modal-overlay">
        <div class="modal-card scan-card slide-up">
            <div class="modal-header">
                <h3>Validar Ticket</h3>
                <button class="close-icon" @click="closeScanModal">✕</button>
            </div>
            
            <div class="modal-body scan-body">
                <div class="qr-container">
                    <img :src="`https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${selectedTicket?.qr_data}`" alt="QR Code" class="qr-real">
                </div>
                
                <h4>{{ selectedTicket?.titulo }}</h4>
                <p class="ticket-hash">{{ selectedTicket?.ticket_id }}</p>

                <div v-if="activeTab === 'upcoming'" class="warning-box">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <p>Al marcar como escaneado, este ticket se considerará <strong>utilizado</strong> y no podrá ser reembolsado.</p>
                </div>
                <div v-else class="info-box">
                    <i class="fa-solid fa-check-double"></i> Ticket archivado / Histórico
                </div>
            </div>

            <div class="modal-footer">
                <button class="btn-cancel" @click="closeScanModal">Cerrar</button>
                
                <button v-if="activeTab === 'upcoming'" class="btn-confirm-scan" @click="confirmScan" :disabled="processing">
                    <i v-if="processing" class="fa-solid fa-spinner fa-spin"></i>
                    {{ processing ? 'Validando...' : 'Marcar como Escaneado' }}
                </button>
            </div>
        </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';

const props = defineProps(['userId']);
const activeTab = ref('upcoming');
const tickets = ref([]);
const loading = ref(false);
const showScanModal = ref(false);
const selectedTicket = ref(null);
const processing = ref(false);

const userId = JSON.parse(localStorage.getItem('user_session'))?.user_id;

// --- COMPUTED: FILTRADO ---
const filteredTickets = computed(() => {
    const now = new Date();
    
    return tickets.value.filter(t => {
        // Corrección de fechas para comparación segura
        const ticketDate = new Date(t.fecha_inicio);
        const isFuture = ticketDate >= now; // Incluye el día de hoy
        const isConfirmed = t.estado === 'Confirmada';
        
        // Asignar clase de estilo
        t.tipo_clase = t.tipo === 'Paquete Turístico' ? 'is-package' : (t.tipo === 'Traslado' ? 'is-transfer' : 'is-service');

        if (activeTab.value === 'upcoming') {
            return isConfirmed && isFuture;
        } else {
            // Historial: Completados, Cancelados O Vencidos (aunque estén confirmados)
            return t.estado === 'Completada' || t.estado === 'Cancelada' || (t.estado === 'Confirmada' && !isFuture);
        }
    });
});

const loadTickets = async () => {
    loading.value = true;
    try {
        // Asegúrate de usar la ruta correcta que definiste en tu backend
        const res = await fetch('http://localhost:3000/api/cart/tickets', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userId })
        });
        const data = await res.json();
        if(data.success) tickets.value = data.data;
    } catch(e) { console.error(e); }
    finally { loading.value = false; }
};

// --- LOGICA DE ESCANEO ---
const openScanner = (t) => {
    selectedTicket.value = t;
    showScanModal.value = true;
};

const confirmScan = async () => {
    processing.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/cart/scan', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ticket_id: selectedTicket.value.ticket_id })
        });
        const data = await res.json();
        
        if(data.success) {
            alert("Ticket validado correctamente. ¡Buen viaje!");
            showScanModal.value = false;
            loadTickets(); // Recargar para moverlo a historial
        } else {
            alert("Error: " + data.message);
        }
    } catch(e) { alert("Error de conexión"); }
    finally { processing.value = false; }
};

const closeScanModal = () => { showScanModal.value = false; selectedTicket.value = null; };

const formatDate = (d) => {
    if(!d) return '';
    return new Date(d).toLocaleDateString('es-VE', { 
        weekday: 'short', day: 'numeric', month: 'short', 
        hour: '2-digit', minute:'2-digit' 
    });
};

onMounted(() => { if(userId) loadTickets(); });
</script>

<style scoped>
.services-container { max-width: 900px; margin: 0 auto; padding: 20px; font-family: 'Segoe UI', sans-serif; }

.header-section { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; border-bottom: 1px solid #e5e7eb; padding-bottom: 15px; }
.header-section h2 { color: #1f2937; margin: 0; }

.tabs-nav { display: flex; gap: 10px; background: #f3f4f6; padding: 5px; border-radius: 8px; }
.tabs-nav button { border: none; background: none; padding: 8px 15px; border-radius: 6px; cursor: pointer; color: #6b7280; font-weight: 600; transition: 0.2s; }
.tabs-nav button.active { background: white; color: #3b82f6; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }

/* TICKET CARD */
.tickets-grid { display: flex; flex-direction: column; gap: 20px; }
.ticket-card { display: flex; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #e5e7eb; position: relative; transition: transform 0.2s; }
.ticket-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }

.ticket-card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: #9ca3af; }
.ticket-card.is-transfer::before { background: #3b82f6; } /* Azul */
.ticket-card.is-service::before { background: #10b981; }  /* Verde */
.ticket-card.is-package::before { background: #8b5cf6; }  /* Morado */

.ticket-left { flex: 1; padding: 20px; display: flex; flex-direction: column; justify-content: center; border-right: 2px dashed #e5e7eb; position: relative; }
/* Muescas */
.ticket-left::after, .ticket-left::before { content: ''; position: absolute; right: -10px; width: 20px; height: 20px; background: #f9fafb; border-radius: 50%; border: 1px solid #e5e7eb; z-index: 1; }
.ticket-left::after { top: -12px; } .ticket-left::before { bottom: -12px; }

.ticket-type { font-size: 0.75rem; text-transform: uppercase; font-weight: 800; color: #9ca3af; letter-spacing: 1px; margin-bottom: 5px; display: block; }
.cancelled-tag { background: #fee2e2; color: #ef4444; padding: 2px 6px; border-radius: 4px; margin-left: 5px; }

.ticket-left h3 { margin: 0 0 5px 0; font-size: 1.2rem; color: #1f2937; }
.subtitle { margin: 0 0 10px 0; color: #6b7280; font-size: 0.9rem; }

.ticket-extra { background: #eff6ff; color: #1e40af; padding: 6px 10px; border-radius: 6px; font-size: 0.85rem; font-weight: 600; width: fit-content; margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }

.ticket-meta { display: flex; gap: 20px; color: #4b5563; font-size: 0.9rem; margin-bottom: 15px; align-items: center; }
.ticket-meta i { color: #3b82f6; margin-right: 5px; }
.end-date { margin-left: 5px; color: #6b7280; }

.passenger-info { background: #f3f4f6; padding: 6px 12px; border-radius: 20px; font-size: 0.8rem; width: fit-content; color: #374151; font-weight: 700; display: flex; align-items: center; gap: 6px; }

.ticket-right { width: 140px; background: #f9fafb; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 15px; gap: 10px; }
.qr-placeholder { font-size: 2.5rem; color: #1f2937; cursor: pointer; display: flex; flex-direction: column; align-items: center; gap: 5px; transition: 0.2s; }
.qr-placeholder span { font-size: 0.7rem; color: #6b7280; }
.qr-placeholder:hover { color: #3b82f6; transform: scale(1.05); }

.ticket-id { font-family: 'Courier New', monospace; font-size: 0.75rem; color: #9ca3af; letter-spacing: 1px; }
.btn-scan { background: #1f2937; color: white; border: none; padding: 8px 12px; border-radius: 6px; font-size: 0.8rem; cursor: pointer; width: 100%; font-weight: 600; }
.btn-scan:hover { background: #000; }
.status-text { font-size: 0.8rem; font-weight: 800; color: #9ca3af; }

/* MODAL SCAN */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); display: flex; justify-content: center; align-items: center; z-index: 2000; }
.modal-card.scan-card { width: 350px; text-align: center; background: white; border-radius: 12px; overflow: hidden; padding: 0; }
.modal-header { padding: 15px; border-bottom: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; background: #f9fafb; }
.modal-header h3 { margin: 0; font-size: 1.1rem; }
.close-icon { background: none; border: none; font-size: 1.2rem; cursor: pointer; }

.modal-body.scan-body { padding: 25px; }
.qr-container { background: white; padding: 10px; border: 1px solid #e5e7eb; border-radius: 8px; display: inline-block; margin-bottom: 15px; }
.qr-real { width: 180px; height: 180px; }
.ticket-hash { font-family: monospace; color: #6b7280; font-size: 0.9rem; margin-bottom: 20px; background: #f3f4f6; display: inline-block; padding: 2px 8px; border-radius: 4px; }

.warning-box { background: #fff7ed; color: #c2410c; padding: 12px; border-radius: 8px; font-size: 0.85rem; border: 1px solid #fed7aa; margin-top: 10px; }
.info-box { background: #f0fdf4; color: #15803d; padding: 12px; border-radius: 8px; font-size: 0.85rem; border: 1px solid #bbf7d0; margin-top: 10px; }

.modal-footer { padding: 15px; background: #f9fafb; border-top: 1px solid #e5e7eb; display: flex; justify-content: flex-end; gap: 10px; }
.btn-confirm-scan { width: 100%; background: #10b981; color: white; border: none; padding: 10px; border-radius: 6px; font-weight: 700; cursor: pointer; }
.btn-confirm-scan:hover { background: #059669; }
.btn-cancel { background: white; border: 1px solid #d1d5db; padding: 10px 15px; border-radius: 6px; cursor: pointer; font-weight: 600; color: #374151; }

.empty-state { text-align: center; padding: 50px; color: #9ca3af; }
.empty-state i { font-size: 3rem; margin-bottom: 15px; }
</style>