<template>
  <div class="payments-container">
    
    <div class="tabs-nav">
      <button :class="{ active: activeTab === 'pendientes' }" @click="activeTab = 'pendientes'">
        <i class="fa-solid fa-clock"></i> Cuotas Pendientes
      </button>
      <button :class="{ active: activeTab === 'historial' }" @click="activeTab = 'historial'">
        <i class="fa-solid fa-receipt"></i> Historial de Pagos
      </button>
    </div>

    <div v-if="activeTab === 'pendientes'" class="tab-content fade-in">
      <div v-if="pendingQuotas.length === 0" class="empty-state">
        <i class="fa-solid fa-check-circle"></i>
        <p>¡Estás al día! No tienes cuotas pendientes.</p>
      </div>

      <div v-else class="quotas-list">
        <div v-for="q in pendingQuotas" :key="q.cuota_id" class="quota-card" :class="q.estado.toLowerCase()">
          <div class="quota-info">
            <div class="quota-header">
              <span class="quota-title">{{ q.concepto }}</span>
              <span class="badge" :class="q.estado.toLowerCase()">{{ q.estado }}</span>
            </div>
            <div class="quota-meta">
              <span>Vence: {{ formatDate(q.fecha_vencimiento) }}</span>
              <small>Ref. Compra #{{ q.compra_id }}</small>
            </div>
          </div>
          
          <div class="quota-action">
            <span class="amount">${{ Number(q.monto).toFixed(2) }}</span>
            <button 
              class="btn-pay" 
              v-if="q.estado !== 'Pagada'"
              @click="openPayModal(q)"
            >
              Pagar
            </button>
            <span v-else class="paid-check"><i class="fa-solid fa-check"></i> Listo</span>
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
              <th>Método</th>
              <th>Monto</th>
              <th>Referencia</th>
              <th>Estado</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in paymentHistory" :key="p.pago_id">
              <td>{{ formatDate(p.fecha) }}</td>
              <td>{{ p.metodo }}</td>
              <td class="font-bold">${{ Number(p.monto).toFixed(2) }}</td>
              <td class="text-muted">{{ p.referencia }}</td>
              <td>
                <span class="badge" :class="p.estado_reembolso === 'Reembolsado' ? 'refunded' : 'success'">
                  {{ p.estado_reembolso === 'Disponible' ? 'Completado' : p.estado_reembolso }}
                </span>
              </td>
              <td>
                <button 
                  v-if="p.estado_reembolso === 'Disponible'" 
                  class="btn-refund" 
                  @click="requestRefund(p.pago_id)"
                  title="Solicitar Reembolso"
                >
                  <i class="fa-solid fa-rotate-left"></i>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-card slide-up">
        <div class="modal-header">
          <h3>Pagar Cuota</h3>
          <button class="close-icon" @click="closeModal">✕</button>
        </div>
        
        <div class="modal-body">
          <div class="summary-box">
            <span>Estás pagando:</span>
            <strong>{{ selectedQuota?.concepto }}</strong>
            <span class="big-price">${{ Number(selectedQuota?.monto).toFixed(2) }}</span>
          </div>

          <label class="label">Método de Pago</label>
          <select v-model="paymentMethod" class="form-control mb-3">
            <option value="zelle">Zelle</option>
            <option value="tarjeta">Tarjeta de Crédito</option>
          </select>

          <div v-if="paymentMethod === 'zelle'">
            <input v-model="paymentData.correo" placeholder="Correo Zelle" class="form-control mb-2">
            <input v-model="paymentData.titular" placeholder="Titular Cuenta" class="form-control mb-2">
            <input v-model="paymentData.referencia" placeholder="# Referencia" class="form-control">
          </div>
          <div v-if="paymentMethod === 'tarjeta'">
            <input v-model="paymentData.numero" placeholder="Número de Tarjeta" class="form-control mb-2">
            <div class="row-2">
                <input v-model="paymentData.vencimiento" type="month" class="form-control">
                <input v-model="paymentData.cvv" placeholder="CVV" maxlength="3" class="form-control">
            </div>
            <input v-model="paymentData.titular" placeholder="Nombre en Tarjeta" class="form-control mt-2">
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn-cancel" @click="closeModal">Cancelar</button>
          <button class="btn-confirm" @click="processPayment" :disabled="processing">
            {{ processing ? 'Procesando...' : 'Confirmar Pago' }}
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue';

const props = defineProps(['userId']); // Recibir ID desde ClientDashboard
const activeTab = ref('pendientes');
const pendingQuotas = ref([]);
const paymentHistory = ref([]);
const showModal = ref(false);
const selectedQuota = ref(null);
const paymentMethod = ref('zelle');
const paymentData = reactive({});
const processing = ref(false);

const userId = JSON.parse(localStorage.getItem('user_session'))?.user_id;

// --- FETCH DATA ---
const loadData = async () => {
  try {
    // Cargar Cuotas
    const resQ = await fetch('http://localhost:3000/api/payments/quotas', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ user_id: userId })
    });
    const dataQ = await resQ.json();
    if(dataQ.success) pendingQuotas.value = dataQ.data;

    // Cargar Historial
    const resH = await fetch('http://localhost:3000/api/payments/history', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ user_id: userId })
    });
    const dataH = await resH.json();
    if(dataH.success) paymentHistory.value = dataH.data;

  } catch(e) { console.error(e); }
};

// --- ACTIONS ---
const openPayModal = (quota) => {
  selectedQuota.value = quota;
  showModal.value = true;
};

const closeModal = () => {
  showModal.value = false;
  selectedQuota.value = null;
  Object.keys(paymentData).forEach(key => paymentData[key] = '');
};

const processPayment = async () => {
  if(!selectedQuota.value) return;
  processing.value = true;

  try {
    const res = await fetch('http://localhost:3000/api/payments/pay', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
            quota_id: selectedQuota.value.cuota_id,
            pago: { metodo: paymentMethod.value, datos: paymentData }
        })
    });
    const data = await res.json();
    
    if(data.success) {
        alert("Pago registrado correctamente");
        closeModal();
        loadData(); // Recargar listas
    } else {
        alert("Error: " + data.message);
    }
  } catch(e) { alert("Error de conexión"); } 
  finally { processing.value = false; }
};

const requestRefund = async (pagoId) => {
  if(!confirm("¿Estás seguro de solicitar el reembolso? Se aplicará una retención del 10%.")) return;
  
  try {
    const res = await fetch('http://localhost:3000/api/payments/refund', {
        method: 'POST', headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ payment_id: pagoId })
    });
    const data = await res.json();
    if(data.success) {
        alert(data.message);
        loadData();
    } else {
        alert(data.message);
    }
  } catch(e) { console.error(e); }
};

// --- HELPERS ---
const formatDate = (d) => new Date(d).toLocaleDateString('es-VE');

onMounted(() => {
  if(userId) loadData();
});
</script>

<style scoped>
.payments-container { padding: 20px; max-width: 900px; margin: 0 auto; }

/* TABS */
.tabs-nav { display: flex; gap: 15px; margin-bottom: 25px; border-bottom: 1px solid #e5e7eb; padding-bottom: 10px; }
.tabs-nav button {
  background: none; border: none; padding: 10px 20px; font-weight: 600; color: #6b7280; cursor: pointer; border-radius: 8px; transition: all 0.2s;
}
.tabs-nav button.active { background-color: #fce7f3; color: #db2777; }
.tabs-nav button:hover:not(.active) { background-color: #f3f4f6; }

/* QUOTAS LIST */
.quotas-list { display: grid; gap: 15px; }
.quota-card {
  background: white; border: 1px solid #e5e7eb; border-radius: 12px; padding: 20px; display: flex; justify-content: space-between; align-items: center;
  border-left: 5px solid transparent;
}
.quota-card.pendiente { border-left-color: #f59e0b; }
.quota-card.vencida { border-left-color: #ef4444; background-color: #fef2f2; }
.quota-card.pagada { border-left-color: #10b981; opacity: 0.7; }

.quota-info { display: flex; flex-direction: column; gap: 5px; }
.quota-title { font-weight: 700; color: #374151; font-size: 1.1rem; }
.quota-meta { color: #9ca3af; font-size: 0.85rem; }

.quota-action { display: flex; align-items: center; gap: 20px; }
.amount { font-weight: 800; font-size: 1.2rem; color: #1f2937; }
.btn-pay { background: #3b82f6; color: white; border: none; padding: 8px 20px; border-radius: 6px; font-weight: 600; cursor: pointer; transition: background 0.2s; }
.btn-pay:hover { background: #2563eb; }
.paid-check { color: #10b981; font-weight: 700; }

/* HISTORY TABLE */
.history-table-wrapper { background: white; border-radius: 12px; overflow: hidden; border: 1px solid #e5e7eb; }
.history-table { width: 100%; border-collapse: collapse; }
.history-table th { background: #f9fafb; padding: 15px; text-align: left; font-size: 0.85rem; color: #6b7280; font-weight: 600; }
.history-table td { padding: 15px; border-top: 1px solid #e5e7eb; color: #374151; }
.btn-refund { background: none; border: 1px solid #e5e7eb; color: #6b7280; width: 32px; height: 32px; border-radius: 6px; cursor: pointer; transition: all 0.2s; }
.btn-refund:hover { background: #fee2e2; color: #ef4444; border-color: #ef4444; }

/* BADGES */
.badge { padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; }
.badge.pendiente { background: #fef3c7; color: #d97706; }
.badge.vencida { background: #fee2e2; color: #991b1b; }
.badge.pagada, .badge.success { background: #d1fae5; color: #065f46; }
.badge.refunded { background: #f3f4f6; color: #374151; text-decoration: line-through; }

/* MODAL */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; }
.modal-card { background: white; width: 90%; max-width: 450px; border-radius: 16px; padding: 25px; box-shadow: 0 10px 25px rgba(0,0,0,0.2); animation: slideUp 0.3s ease-out; }
@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

.modal-header { display: flex; justify-content: space-between; margin-bottom: 20px; }
.modal-header h3 { margin: 0; }
.close-icon { background: none; border: none; font-size: 1.2rem; cursor: pointer; }

.summary-box { background: #f3f4f6; padding: 15px; border-radius: 8px; text-align: center; margin-bottom: 20px; display: flex; flex-direction: column; gap: 5px; }
.big-price { font-size: 1.5rem; font-weight: 800; color: #3b82f6; }

.form-control { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; margin-bottom: 10px; }
.row-2 { display: flex; gap: 10px; }
.btn-confirm { width: 100%; padding: 12px; background: #10b981; color: white; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; }
.btn-confirm:hover { background: #059669; }
.btn-cancel { width: 100%; padding: 10px; background: white; color: #6b7280; border: none; cursor: pointer; margin-top: 10px; }

</style>