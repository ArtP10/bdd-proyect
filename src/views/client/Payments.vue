<template>
  <div class="payments-container">
    
    <div class="tabs-nav">
      <button :class="{ active: activeTab === 'pendientes' }" @click="activeTab = 'pendientes'">
        <i class="fa-solid fa-clock"></i> Cuotas Pendientes
      </button>
      <button :class="{ active: activeTab === 'historial' }" @click="activeTab = 'historial'">
        <i class="fa-solid fa-receipt"></i> Historial de Pagos
      </button>
      <button :class="{ active: activeTab === 'reembolsos' }" @click="activeTab = 'reembolsos'">
        <i class="fa-solid fa-rotate-left"></i> Reembolsos
      </button>
    </div>

    <div v-if="activeTab === 'pendientes'" class="tab-content fade-in">
      <div v-if="pendingQuotas.length === 0" class="empty-state">
        <i class="fa-solid fa-check-circle"></i>
        <p>¡Estás al día! No tienes cuotas pendientes.</p>
      </div>

      <div v-else class="quotas-list">
        <div v-for="(q, index) in pendingQuotas" :key="index" class="quota-card" :class="q.estado.toLowerCase()">
          <div class="quota-info">
            <div class="quota-header">
              <span class="quota-title">{{ q.concepto }}</span>
              <span class="badge" :class="q.estado.toLowerCase()">{{ q.estado }}</span>
            </div>
            <div class="quota-meta">
              <span><i class="fa-regular fa-calendar"></i> Vence: {{ formatDate(q.fecha_vencimiento) }}</span>
            </div>
          </div>
          
          <div class="quota-action">
            <span class="amount">${{ Number(q.monto).toFixed(2) }}</span>
            
            <button 
              class="btn-pay" 
              v-if="q.estado === 'Pendiente'" 
              @click="openPayModal(q)"
            >
              Pagar
            </button>
            
            <span v-else class="paid-check">
                <i v-if="q.estado === 'Pagada'" class="fa-solid fa-check"></i>
                <i v-if="q.estado === 'Cancelada'" class="fa-solid fa-ban"></i>
                {{ q.estado === 'Pagada' ? 'Listo' : q.estado }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <div v-if="activeTab === 'historial'" class="tab-content fade-in">
      <div class="history-table-wrapper">
        <table class="history-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Monto</th>
              <th>Tasa</th>
              <th>Equivalente</th>
              <th>Ref</th>
              <th>Estado</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(p, index) in paymentHistory" :key="index" :class="{ 'row-refund': p.monto_original < 0 }">
              <td>{{ formatDate(p.fecha) }}</td>
              
              <td class="font-bold" :class="{'text-red': p.monto_original < 0}">
                {{ Number(p.monto_original).toFixed(2) }} 
                <span class="currency-tag">{{ p.moneda_original }}</span>
              </td>

              <td class="text-muted">{{ Number(p.tasa_aplicada).toFixed(2) }}</td>
              <td class="usd-col" :class="{'text-red': p.monto_usd < 0}">
                  ${{ Number(p.monto_usd).toFixed(2) }}
              </td>
              <td class="text-muted">{{ p.referencia }}</td>
              <td>
                <span class="badge" :class="p.estado_reembolso === 'Reembolsado' ? 'refunded' : 'success'">
                  {{ p.monto_original < 0 ? 'REVERSO' : p.estado_reembolso }}
                </span>
              </td>
              <td>
                <button v-if="p.es_reembolsable" 
                  class="btn-refund" 
                  @click="initiateRefund(p)" 
                  title="Solicitar Reembolso del Viaje Completo">
                  <i class="fa-solid fa-rotate-left"></i>
                </button>
                
                <span v-else-if="p.estado_reembolso === 'Reembolsado' && p.monto_original > 0" 
                      class="badge refunded-static">
                    Cancelado
                </span>

                <span v-else class="text-muted text-xs"> - </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="activeTab === 'reembolsos'" class="tab-content fade-in">
      <div v-if="refundsList.length === 0" class="empty-state">
        <i class="fa-solid fa-file-invoice-dollar"></i>
        <p>No tienes reembolsos procesados.</p>
      </div>
      <div v-else class="history-table-wrapper">
        <table class="history-table">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Compra #</th>
              <th>Tipo</th>
              <th>Devuelto</th>
              <th>Tasa</th> 
              <th>Penalización</th>
              <th>Detalle</th> 
            </tr>
          </thead>
          <tbody>
            <tr v-for="(r, index) in refundsList" :key="index">
              <td>{{ formatDate(r.fecha) }}</td>
              <td>#{{ r.compra_id }}</td>
              <td>
                  <span class="badge" :class="r.monto_reembolsado > 0 ? 'success' : 'pendiente'">
                      {{ r.tipo_resolucion }}
                  </span>
              </td>
              <td class="font-bold text-green">+{{ Number(r.monto_reembolsado).toFixed(2) }} {{ r.moneda_original }}</td>
              <td class="text-muted text-xs">
                  <span v-if="r.moneda_original !== 'USD'">1 USD = {{ Number(r.tasa_valor).toFixed(2) }} {{ r.moneda_original }}</span>
                  <span v-else>N/A</span>
              </td>
              <td class="text-red">-{{ Number(r.monto_retenido).toFixed(2) }} {{ r.moneda_original }}</td>
              <td>
                  <button class="btn-detail" @click="openDetail(r.compra_id)">
                      <i class="fa-solid fa-eye"></i> Ver Items
                  </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <PaymentModal 
        :is-open="showPayModal"
        :amount="selectedQuota ? Number(selectedQuota.monto) : 0"
        :allow-miles="false" 
        @close="closePayModal"
        @payment-success="handlePaymentSuccess"
    />

    <div v-if="showRefundModal" class="modal-overlay">
        <div class="modal-card refund-card slide-up">
            <div class="modal-header refund-header">
                <h3><i class="fa-solid fa-triangle-exclamation"></i> Confirmar Cancelación</h3>
                <button class="close-icon" @click="closeRefundModal">✕</button>
            </div>
            
            <div class="modal-body" v-if="refundData">
                <p class="alert-text">
                    Se cancelará el viaje completo. 
                    <br>
                    <strong>Moneda de devolución: {{ refundData.moneda_retorno }}</strong>
                </p>
                
                <div class="refund-details">
                    <div class="detail-row">
                        <span>Total Pagado:</span>
                        <span>{{ Number(refundData.total_pagado).toFixed(2) }} {{ refundData.moneda_retorno }}</span>
                    </div>
                    <div class="detail-row penalization">
                        <span>Menos Penalización (10%):</span>
                        <span>- {{ Number(refundData.penalizacion).toFixed(2) }} {{ refundData.moneda_retorno }}</span>
                    </div>
                    <hr>
                    <div class="detail-row total-refund">
                        <span>A devolver a tu cuenta:</span> 
                        <strong>{{ Number(refundData.monto_a_devolver).toFixed(2) }} {{ refundData.moneda_retorno }}</strong>
                    </div>
                </div>

                <div class="tickets-preview" v-if="refundData.items_afectados">
                    <small>Items a cancelar:</small>
                    <ul>
                        <li v-for="(item, i) in refundData.items_afectados" :key="i">
                            {{ item.nombre }} <span v-if="item.fecha !== 'N/A'">({{ item.fecha }})</span>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="modal-footer">
                <button class="btn-cancel" @click="closeRefundModal">Volver</button>
                <button class="btn-confirm-refund" @click="confirmRefund" :disabled="processing">
                    <i v-if="processing" class="fa-solid fa-spinner fa-spin"></i>
                    {{ processing ? 'Procesando...' : 'Confirmar Cancelación' }}
                </button>
            </div>
        </div>
    </div>

    <PurchaseDetailModal 
        :is-open="showDetailModal" 
        :compra-id="selectedDetailId"
        @close="showDetailModal = false"
    />

  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import PaymentModal from './PaymentModal.vue';
import PurchaseDetailModal from './PurchaseDetailModal.vue';

// Variables de estado
const showDetailModal = ref(false);
const selectedDetailId = ref(null);

// Función para abrir el modal
const openDetail = (compraId) => { 
    selectedDetailId.value = compraId; 
    showDetailModal.value = true; 
};

const props = defineProps(['userId']); 
const activeTab = ref('pendientes');
const pendingQuotas = ref([]);
const paymentHistory = ref([]);
const refundsList = ref([]);
const processing = ref(false);

const showPayModal = ref(false);
const showRefundModal = ref(false);
const selectedQuota = ref(null);
const refundData = ref(null);
const selectedPurchaseId = ref(null);

const userId = JSON.parse(localStorage.getItem('user_session'))?.user_id;

const loadData = async () => {
  try {
    const resQ = await fetch('http://localhost:3000/api/payments/quotas', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ user_id: userId })
    });
    const dataQ = await resQ.json();
    if(dataQ.success) pendingQuotas.value = dataQ.data;

    const resH = await fetch('http://localhost:3000/api/payments/history', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ user_id: userId })
    });
    const dataH = await resH.json();
    if(dataH.success) paymentHistory.value = dataH.data;

    const resR = await fetch('http://localhost:3000/api/payments/refunds-list', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ user_id: userId })
    });
    const dataR = await resR.json();
    if(dataR.success) refundsList.value = dataR.data;

  } catch(e) { console.error(e); }
};

// --- PAGOS ---
const openPayModal = (quota) => { selectedQuota.value = quota; showPayModal.value = true; };
const closePayModal = () => { showPayModal.value = false; selectedQuota.value = null; };

const handlePaymentSuccess = async (paymentPayload) => {
  if(!selectedQuota.value) return;
  showPayModal.value = false;
  processing.value = true;
  try {
    const payload = {
        quota_id: selectedQuota.value.cuota_id,
        origen: 'cuota',
        pago: paymentPayload,
        monto: selectedQuota.value.monto
    };
    const res = await fetch('http://localhost:3000/api/payments/pay-quota', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(payload)
    });
    const data = await res.json();
    if(data.success) { alert("Pago registrado correctamente"); loadData(); } 
    else { alert("Error: " + data.message); }
  } catch(e) { alert("Error de conexión"); } 
  finally { processing.value = false; }
};

// --- REEMBOLSOS ---
const initiateRefund = async (p) => { selectedPurchaseId.value = p.compra_id; initRefund(p); };

const initRefund = async (p) => {
    try {
        const res = await fetch('http://localhost:3000/api/payments/preview-refund', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ compra_id: p.compra_id })
        });
        const data = await res.json();
        if(data.success) { refundData.value = data.data; showRefundModal.value = true; }
        else { alert("Error al consultar reembolso: " + data.message); }
    } catch(e) { console.error(e); }
};

const confirmRefund = async () => {
    processing.value = true;
    try {
        const res = await fetch('http://localhost:3000/api/payments/refund', {
            method: 'POST', headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ compra_id: selectedPurchaseId.value })
        });
        const data = await res.json();
        if(data.success) { alert(data.message); showRefundModal.value = false; loadData(); }
        else { alert("Error: " + data.message); }
    } catch(e) { alert("Error procesando solicitud"); } 
    finally { processing.value = false; }
};

const closeRefundModal = () => { showRefundModal.value = false; refundData.value = null; };
const formatDate = (d) => new Date(d).toLocaleDateString('es-VE');

onMounted(() => { if(userId) loadData(); });
</script>

<style scoped>
.payments-container { padding: 20px; max-width: 900px; margin: 0 auto; font-family: 'Segoe UI', sans-serif; }

/* Tabs */
.tabs-nav { display: flex; gap: 15px; margin-bottom: 25px; border-bottom: 1px solid #e5e7eb; padding-bottom: 10px; }
.tabs-nav button { background: none; border: none; padding: 10px 20px; font-weight: 600; color: #6b7280; cursor: pointer; border-radius: 8px; transition: all 0.2s; display: flex; align-items: center; gap: 8px; }
.tabs-nav button.active { background-color: #eff6ff; color: #3b82f6; }
.tabs-nav button:hover:not(.active) { background-color: #f3f4f6; }

/* Tablas y Listas */
.quotas-list { display: grid; gap: 15px; }
.quota-card { background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 5px rgba(0,0,0,0.02); border-left: 5px solid transparent; transition: transform 0.2s; }
.quota-card:hover { transform: translateY(-2px); box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
.quota-card.pendiente { border-left-color: #f59e0b; }
.quota-card.vencida { border-left-color: #ef4444; background-color: #fef2f2; }
.quota-card.pagada { border-left-color: #10b981; opacity: 0.7; }
.quota-card.cancelada { border-left-color: #9ca3af; opacity: 0.6; background-color: #f3f4f6; }

.quota-info { display: flex; flex-direction: column; gap: 5px; }
.quota-title { font-weight: 700; color: #374151; font-size: 1.05rem; }
.quota-meta { color: #6b7280; font-size: 0.85rem; display: flex; gap: 10px; align-items: center; }
.quota-action { display: flex; align-items: center; gap: 20px; }
.amount { font-weight: 800; font-size: 1.2rem; color: #1f2937; }

/* Botón de pago y check */
.btn-pay { background: #3b82f6; color: white; border: none; padding: 8px 20px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
.btn-pay:hover { background: #2563eb; }
.paid-check { font-weight: 700; color: #6b7280; display: flex; align-items: center; gap: 5px; }
.paid-check .fa-check { color: #10b981; }
.paid-check .fa-ban { color: #ef4444; }

.history-table-wrapper { background: white; border-radius: 12px; overflow: hidden; border: 1px solid #e5e7eb; margin-top: 10px; box-shadow: 0 2px 5px rgba(0,0,0,0.02); }
.history-table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
.history-table th { background: #f9fafb; padding: 15px; text-align: left; color: #6b7280; font-weight: 600; border-bottom: 2px solid #e5e7eb; }
.history-table td { padding: 15px; border-bottom: 1px solid #f3f4f6; color: #374151; vertical-align: middle; }

/* Estilos especiales */
.row-refund { background-color: #fef2f2; }
.text-red { color: #dc2626; font-weight: bold; }
.text-green { color: #10b981; font-weight: bold; }
.text-xs { font-size: 0.75rem; }
.currency-tag { font-size: 0.75rem; background: #e5e7eb; padding: 2px 6px; border-radius: 4px; font-weight: 700; color: #4b5563; margin-left: 5px; }

/* Badges */
.badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
.badge.pendiente { background: #fffbeb; color: #d97706; }
.badge.success { background: #d1fae5; color: #065f46; }
.badge.refunded { background: #f3f4f6; color: #374151; text-decoration: line-through; }
.badge.cancelada { background: #e5e7eb; color: #374151; }

.btn-refund { background: none; border: 1px solid #e5e7eb; color: #6b7280; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: all 0.2s; }
.btn-refund:hover { background: #fee2e2; color: #ef4444; border-color: #ef4444; }

.btn-detail { background: white; border: 1px solid #cbd5e1; color: #475569; padding: 5px 10px; border-radius: 6px; cursor: pointer; font-size: 0.8rem; transition: all 0.2s; }
.btn-detail:hover { background: #f1f5f9; border-color: #94a3b8; color: #1e293b; }

/* Empty state */
.empty-state { text-align: center; padding: 40px; color: #9ca3af; }
.empty-state i { font-size: 3rem; margin-bottom: 10px; color: #d1d5db; }

/* Modales */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-card { background: white; width: 90%; max-width: 450px; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
.refund-card { border-top: 5px solid #ef4444; }
.modal-header.refund-header { background: #fef2f2; color: #991b1b; padding: 15px; display: flex; justify-content: space-between; align-items: center; }
.close-icon { background: none; border: none; cursor: pointer; font-size: 1.2rem; }
.modal-body { padding: 20px; }
.tickets-preview { margin-top: 15px; background: #fff; border: 1px solid #e5e7eb; padding: 10px; border-radius: 8px; max-height: 150px; overflow-y: auto; }
.tickets-preview small { font-weight: 700; color: #6b7280; display: block; margin-bottom: 5px; }
.tickets-preview ul { list-style: none; padding: 0; margin: 0; }
.tickets-preview li { font-size: 0.85rem; color: #374151; padding: 3px 0; border-bottom: 1px solid #f3f4f6; }

.refund-details { background: #f9fafb; padding: 15px; border-radius: 8px; border: 1px solid #e5e7eb; margin-bottom: 15px; }
.detail-row { display: flex; justify-content: space-between; margin-bottom: 5px; }
.detail-row.penalization { color: #dc2626; }
.detail-row.total-refund { font-size: 1.1rem; color: #1f2937; font-weight: bold; border-top: 1px dashed #d1d5db; padding-top: 10px; margin-top: 5px; }
.modal-footer { padding: 15px; background: #f9fafb; border-top: 1px solid #e5e7eb; display: flex; justify-content: flex-end; gap: 10px; }
.btn-confirm-refund { background: #dc2626; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }
.btn-cancel { background: white; border: 1px solid #d1d5db; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
</style>