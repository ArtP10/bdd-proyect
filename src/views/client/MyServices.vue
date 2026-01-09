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
                
                <div v-else class="history-actions">
                    <span class="status-text" :class="t.estado.toLowerCase()">
                        {{ t.estado === 'Completada' ? 'USADO' : (t.estado === 'Cancelada' ? 'CANCELADO' : 'VENCIDO') }}
                    </span>
                    
                    <div v-if="t.reclamo_estado" class="claim-badge" :class="t.reclamo_estado.toLowerCase()">
                        <div class="claim-header">
                            <i class="fa-solid fa-triangle-exclamation"></i> 
                            {{ t.reclamo_estado === 'Abierto' ? 'Reclamo Abierto' : 'Reclamo Cerrado' }}
                        </div>
                        <button v-if="t.reclamo_estado === 'Cerrado'" @click="showResponse(t)" class="btn-see-response">
                            Ver respuesta
                        </button>
                    </div>

                    <div v-if="t.estado === 'Completada' && !t.reclamo_estado" class="btn-group">
                        <button class="btn-action btn-review" @click="openReviewModal(t)" title="Calificar">
                            <i class="fa-regular fa-star"></i>
                        </button>
                        <button class="btn-action btn-claim" @click="openClaimModal(t)" title="Reclamar">
                            <i class="fa-solid fa-bullhorn"></i>
                        </button>
                    </div>
                </div>
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
                    <p>Al marcar como escaneado, este ticket se considerará <strong>utilizado</strong>.</p>
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

    <div v-if="showReviewModal" class="modal-overlay">
        <div class="modal-card review-card slide-up">
            <div class="modal-header">
                <h3>Califica tu experiencia</h3>
                <button class="close-icon" @click="closeReviewModal">✕</button>
            </div>
            <div class="modal-body">
                <p class="subtitle-center">{{ selectedTicket?.titulo }}</p>
                <div class="form-body">
                    <label>Valoración:</label>
                    <div class="stars-wrapper">
                        <StarRating v-model="reviewForm.rating" />
                    </div>
                    <label>Tu opinión (Máx 400):</label>
                    <textarea v-model="reviewForm.comment" maxlength="400" placeholder="Cuéntanos los detalles..."></textarea>
                    <small class="char-count">{{ reviewForm.comment.length }}/400</small>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" @click="closeReviewModal">Cancelar</button>
                <button class="btn-submit" @click="submitReview" :disabled="processing">
                    {{ processing ? 'Enviando...' : 'Publicar' }}
                </button>
            </div>
        </div>
    </div>

    <div v-if="showClaimModal" class="modal-overlay">
        <div class="modal-card review-card slide-up">
            <div class="modal-header header-claim">
                <h3>Reportar Incidente</h3>
                <button class="close-icon" @click="showClaimModal = false">✕</button>
            </div>
            <div class="modal-body">
                <p class="subtitle-center">{{ selectedTicket?.titulo }}</p>
                <div class="warning-box" style="margin-bottom: 10px;">
                    <small>Por favor describe el problema detalladamente. Nuestro equipo administrativo revisará tu caso.</small>
                </div>
                <label>Detalle del problema:</label>
                <textarea v-model="claimText" placeholder="¿Qué salió mal?" class="claim-input"></textarea>
            </div>
            <div class="modal-footer">
                <button class="btn-cancel" @click="showClaimModal = false">Cancelar</button>
                <button class="btn-claim-submit" @click="submitClaim" :disabled="processing">
                    {{ processing ? 'Enviando...' : 'Reportar' }}
                </button>
            </div>
        </div>
    </div>

    <div v-if="showResponseModal" class="modal-overlay" @click.self="showResponseModal = false">
        <div class="modal-card response-card slide-up">
            <div class="modal-header header-response">
                <h3><i class="fa-solid fa-envelope-open-text"></i> Respuesta de ViajesUCAB</h3>
                <button class="close-icon" @click="showResponseModal = false">✕</button>
            </div>
            <div class="modal-body response-body">
                <p class="response-intro">Estimado cliente, con respecto a su ticket <strong>{{ selectedTicket?.ticket_id }}</strong>:</p>
                <div class="response-box">
                    <p>{{ selectedTicket?.reclamo_respuesta || "Sin detalles adicionales." }}</p>
                </div>
                <div class="response-footer-text">
                    <small>Gracias por su paciencia.</small>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn-primary-modal" @click="showResponseModal = false">Entendido</button>
            </div>
        </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue';
import StarRating from '../components/common/StarRating.vue'; 

const props = defineProps(['userId']);
const activeTab = ref('upcoming');
const tickets = ref([]);
const loading = ref(false);
const processing = ref(false);

// Estado Modales
const showScanModal = ref(false);
const showReviewModal = ref(false);
const showClaimModal = ref(false);
const showResponseModal = ref(false); // Nuevo Modal
const selectedTicket = ref(null);

const userId = JSON.parse(localStorage.getItem('user_session'))?.user_id;

// Datos Formularios
const reviewForm = reactive({ rating: 0, comment: '' });
const claimText = ref('');

// --- COMPUTED ---
const filteredTickets = computed(() => {
    const now = new Date();
    return tickets.value.filter(t => {
        const ticketDate = new Date(t.fecha_inicio);
        const isFuture = ticketDate >= now; 
        const isConfirmed = t.estado === 'Confirmada';
        
        t.tipo_clase = t.tipo === 'Paquete Turístico' ? 'is-package' : (t.tipo === 'Traslado' ? 'is-transfer' : 'is-service');

        if (activeTab.value === 'upcoming') {
            return isConfirmed && isFuture;
        } else {
            return t.estado === 'Completada' || t.estado === 'Cancelada' || (t.estado === 'Confirmada' && !isFuture);
        }
    });
});

const loadTickets = async () => {
    loading.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/cart/tickets', {
            method: 'POST', 
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ user_id: userId })
        });
        const data = await res.json();
        if(data.success) {
            tickets.value = data.data.map(t => {
                let prefix = 'GEN';
                const tipo = t.tipo ? t.tipo.toUpperCase() : '';
                if (tipo.includes('TRASLADO') || tipo.includes('VUELO')) prefix = 'TRS';
                else if (tipo.includes('SERVICIO') || tipo.includes('TOUR')) prefix = 'SRV';
                else if (tipo.includes('PAQUETE')) prefix = 'PAQ';

                const compositeId = `${prefix}-${t.fk_compra}-${t.det_res_codigo}`;
                return { ...t, ticket_id: compositeId, qr_data: compositeId };
            });
        }
    } catch(e) { console.error(e); } 
    finally { loading.value = false; }
};

// --- SCAN ---
const openScanner = (t) => { selectedTicket.value = t; showScanModal.value = true; };
const closeScanModal = () => { showScanModal.value = false; selectedTicket.value = null; };
const confirmScan = async () => {
    processing.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/cart/scan', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ticket_id: selectedTicket.value.ticket_id })
        });
        const data = await res.json();
        if(data.success) {
            alert("Ticket validado correctamente.");
            showScanModal.value = false;
            loadTickets(); 
        } else alert("Error: " + data.message);
    } catch(e) { alert("Error de conexión"); }
    finally { processing.value = false; }
};

// --- REVIEW ---
const openReviewModal = (t) => { selectedTicket.value = t; reviewForm.rating = 5; reviewForm.comment = ''; showReviewModal.value = true; };
const closeReviewModal = () => { showReviewModal.value = false; };
const submitReview = async () => {
    if(reviewForm.rating === 0) return alert("Selecciona una calificación.");
    processing.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/reviews/create', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ticket_id: selectedTicket.value.ticket_id, rating: reviewForm.rating, comment: reviewForm.comment })
        });
        const data = await res.json();
        if(data.success) { alert('¡Gracias por tu opinión!'); closeReviewModal(); } 
        else alert(data.message);
    } catch(e) { console.error(e); } 
    finally { processing.value = false; }
};

// --- CLAIM ---
const openClaimModal = (t) => { selectedTicket.value = t; claimText.value = ''; showClaimModal.value = true; };
const submitClaim = async () => {
    if(!claimText.value) return alert("Escribe el motivo del reclamo.");
    processing.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/claims/create', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ ticket_id: selectedTicket.value.ticket_id, content: claimText.value })
        });
        const data = await res.json();
        if(data.success) {
            alert(data.message);
            showClaimModal.value = false;
            loadTickets();
        } else alert(data.message);
    } catch(e) { console.error(e); } 
    finally { processing.value = false; }
};

// --- RESPUESTA (NUEVO) ---
const showResponse = (t) => {
    selectedTicket.value = t;
    showResponseModal.value = true; // Abre el modal en lugar del alert
};

const formatDate = (d) => {
    if(!d) return '';
    return new Date(d).toLocaleDateString('es-VE', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute:'2-digit' });
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

/* GRID Y CARDS - Estilos Restaurados y Mejorados */
.tickets-grid { display: flex; flex-direction: column; gap: 20px; }
.ticket-card { display: flex; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #e5e7eb; position: relative; transition: transform 0.2s; align-items: stretch; }
.ticket-card:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(0,0,0,0.1); }

/* Barra de color lateral */
.ticket-card::before { content: ''; position: absolute; left: 0; top: 0; bottom: 0; width: 6px; background: #9ca3af; z-index: 2; }
.ticket-card.is-transfer::before { background: #3b82f6; } 
.ticket-card.is-service::before { background: #10b981; }  
.ticket-card.is-package::before { background: #8b5cf6; }  

/* Layout Ticket - IZQUIERDA */
.ticket-left { flex: 1; padding: 20px; display: flex; flex-direction: column; justify-content: center; border-right: 2px dashed #e5e7eb; position: relative; min-width: 0; }

/* Muescas (Círculos decorativos) */
.ticket-left::after, .ticket-left::before { content: ''; position: absolute; right: -10px; width: 20px; height: 20px; background: #f9fafb; border-radius: 50%; border: 1px solid #e5e7eb; z-index: 1; }
.ticket-left::after { top: -12px; } 
.ticket-left::before { bottom: -12px; }

/* Layout Ticket - DERECHA (Ajustado para que quepa todo) */
.ticket-right { width: 180px; flex-shrink: 0; background: #f9fafb; display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 15px; gap: 10px; text-align: center; }

/* Tipografía */
.ticket-type { font-size: 0.75rem; text-transform: uppercase; font-weight: 800; color: #9ca3af; letter-spacing: 1px; margin-bottom: 5px; display: block; }
.ticket-left h3 { margin: 0 0 5px 0; font-size: 1.2rem; color: #1f2937; }
.subtitle { margin: 0 0 10px 0; color: #6b7280; font-size: 0.9rem; }
.ticket-id { font-family: 'Courier New', monospace; font-size: 0.75rem; color: #9ca3af; letter-spacing: 1px; margin-bottom: 5px; }

/* Status Text */
.status-text { font-size: 0.8rem; font-weight: 800; color: #9ca3af; text-transform: uppercase; margin-bottom: 5px; display: block; }
.status-text.completada { color: #10b981; }
.status-text.cancelada { color: #ef4444; }

/* Botones Nuevos */
.history-actions { display: flex; flex-direction: column; align-items: center; gap: 8px; width: 100%; }
.btn-group { display: flex; gap: 5px; width: 100%; margin-top: 5px; }
.btn-action { flex: 1; padding: 6px; border-radius: 6px; cursor: pointer; font-size: 0.9rem; border: 1px solid; background: white; display: flex; justify-content: center; align-items: center; transition: all 0.2s; }
.btn-review { border-color: #f59e0b; color: #f59e0b; }
.btn-review:hover { background: #f59e0b; color: white; }
.btn-claim { border-color: #ef4444; color: #ef4444; }
.btn-claim:hover { background: #ef4444; color: white; }

/* Badge de Reclamo */
.claim-badge { font-size: 0.75rem; padding: 6px; border-radius: 6px; width: 100%; text-align: center; margin-top: 5px; display: flex; flex-direction: column; align-items: center; gap: 2px; }
.claim-badge.abierto { background: #fff7ed; color: #c2410c; border: 1px solid #fed7aa; }
.claim-badge.cerrado { background: #f0fdf4; color: #15803d; border: 1px solid #bbf7d0; }
.btn-see-response { background: none; border: none; text-decoration: underline; color: inherit; cursor: pointer; font-weight: bold; font-size: 0.75rem; padding: 0; }

/* QR Placeholder */
.qr-placeholder { font-size: 2rem; color: #1f2937; cursor: pointer; display: flex; flex-direction: column; align-items: center; gap: 2px; transition: 0.2s; margin-bottom: 5px; }
.qr-placeholder span { font-size: 0.7rem; color: #6b7280; }
.qr-placeholder:hover { color: #3b82f6; transform: scale(1.05); }

/* Scan Button */
.btn-scan { background: #1f2937; color: white; border: none; padding: 8px 12px; border-radius: 6px; font-size: 0.8rem; cursor: pointer; width: 100%; font-weight: 600; }
.btn-scan:hover { background: #000; }

/* MODALES GENERALES */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); display: flex; justify-content: center; align-items: center; z-index: 2000; backdrop-filter: blur(4px); }
.modal-card { width: 350px; background: white; border-radius: 12px; overflow: hidden; padding: 0; animation: slideUp 0.3s ease-out; }
.review-card { width: 450px; }
.response-card { width: 500px; }

/* Estilos Específicos Modal Respuesta */
.header-response { background: #f0fdf4; color: #14532d; }
.response-body { padding: 25px; text-align: left; }
.response-intro { color: #374151; margin-bottom: 15px; }
.response-box { background: #f9fafb; padding: 15px; border-left: 4px solid #10b981; border-radius: 4px; color: #1f2937; font-style: italic; line-height: 1.5; margin-bottom: 20px; }
.response-footer-text { text-align: center; color: #9ca3af; }
.btn-primary-modal { background: #10b981; color: white; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; font-weight: 700; }
.btn-primary-modal:hover { background: #059669; }

/* Estilos Modal Reclamo */
.header-claim { background: #fef2f2; color: #991b1b; }
.modal-header { padding: 15px; border-bottom: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; background: #f9fafb; }
.modal-body { padding: 25px; }
.claim-input { width: 100%; height: 100px; padding: 10px; border: 1px solid #e5e7eb; border-radius: 8px; margin-top: 5px; resize: none; font-family: inherit; }
.btn-claim-submit { background: #ef4444; color: white; border: none; padding: 10px 16px; border-radius: 6px; font-weight: 700; cursor: pointer; }
.btn-submit { background: #f59e0b; color: white; border: none; padding: 10px 16px; border-radius: 6px; font-weight: 700; cursor: pointer; }
.btn-cancel { background: white; border: 1px solid #d1d5db; padding: 10px 15px; border-radius: 6px; cursor: pointer; font-weight: 600; color: #374151; }

@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

/* Helpers */
.qr-container { background: white; padding: 10px; border: 1px solid #e5e7eb; border-radius: 8px; display: inline-block; margin-bottom: 15px; }
.qr-real { width: 180px; height: 180px; }
.warning-box { background: #fff7ed; color: #c2410c; padding: 12px; border-radius: 8px; font-size: 0.85rem; border: 1px solid #fed7aa; }
.info-box { background: #f0fdf4; color: #15803d; padding: 12px; border-radius: 8px; font-size: 0.85rem; border: 1px solid #bbf7d0; margin-top: 10px; }
.empty-state { text-align: center; padding: 50px; color: #9ca3af; }
.empty-state i { font-size: 3rem; margin-bottom: 15px; }
.stars-wrapper { margin-bottom: 20px; text-align: center; font-size: 1.5rem; }
.char-count { display: block; text-align: right; font-size: 0.75rem; color: #9ca3af; margin-top: 4px; }
</style>