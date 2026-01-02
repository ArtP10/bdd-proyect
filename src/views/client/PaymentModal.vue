<template>
  <div v-if="isOpen" class="modal-overlay" @click.self="close">
    <div class="modal-card">
      <div class="modal-header">
        <h3>Procesar Pago</h3>
        <button class="close-btn" @click="close">×</button>
      </div>

      <div class="modal-body">
        <div class="amount-display">
          <label>Monto a Pagar (USD)</label>
          <div class="amount-value">${{ amount.toFixed(2) }}</div>
        </div>

        <div class="form-group">
          <label>Moneda de Pago</label>
          <select v-model="selectedCurrency" class="form-control">
            <option v-for="rate in rates" :key="rate.code" :value="rate">
              {{ rate.code }} - Tasa: {{ rate.value }}
            </option>
          </select>
        </div>

        <div class="conversion-box" v-if="selectedCurrency.code !== 'USD'">
            Total en {{ selectedCurrency.code }}: 
            <strong>{{ (amount * selectedCurrency.value).toFixed(2) }}</strong>
        </div>

        <div class="form-group mt-3">
          <label>Método de Pago</label>
          <div class="methods-grid">
            <button v-for="m in availableMethods" :key="m.id" 
                :class="['method-btn', { active: selectedMethod === m.id }]"
                @click="resetDataAndSelect(m.id)">
                <i :class="m.icon"></i> {{ m.label }}
            </button>
          </div>
        </div>

        <div class="dynamic-form mt-3" v-if="selectedMethod">
            
            <div v-if="selectedMethod === 'zelle'">
                <input v-model="paymentData.correo" placeholder="Correo Zelle" class="form-control mb-2">
                <input v-model="paymentData.titular" placeholder="Titular Cuenta" class="form-control mb-2">
                <input v-model="paymentData.referencia" placeholder="# Confirmación" class="form-control">
            </div>

            <div v-if="selectedMethod === 'credito' || selectedMethod === 'debito'">
                <input v-model="paymentData.numero" placeholder="Número de Tarjeta (16 dígitos)" maxlength="16" class="form-control mb-2">
                <div class="row-half">
                    <input v-model="paymentData.vencimiento" type="month" class="form-control" title="Vencimiento">
                    <input v-model="paymentData.cvv" placeholder="CVV" maxlength="3" class="form-control">
                </div>
                <input v-model="paymentData.banco" placeholder="Banco Emisor" class="form-control mt-2">
                <input v-model="paymentData.titular" placeholder="Nombre en la Tarjeta" class="form-control mt-2">
            </div>

            <div v-if="selectedMethod === 'movil'">
                <input v-model="paymentData.referencia" placeholder="Ref. Operación (últimos 4-6 dígitos)" class="form-control">
                <p class="help-text">Banco Destino: 0102 (Venezuela) - Tel: 0414-XXX-XXXX</p>
            </div>

            <div v-if="selectedMethod === 'transferencia'">
                <input v-model="paymentData.cuenta" placeholder="Cuenta Emisora (20 dígitos)" maxlength="20" class="form-control mb-2">
                <input v-model="paymentData.referencia" placeholder="Nro Referencia" class="form-control">
            </div>

            <div v-if="selectedMethod === 'cheque'">
                <input v-model="paymentData.numero_cheque" placeholder="Número de Cheque" class="form-control mb-2">
                <input v-model="paymentData.cuenta" placeholder="Cuenta del Cliente" class="form-control mb-2">
                <input v-model="paymentData.banco" placeholder="Banco Emisor" class="form-control mb-2">
                <input v-model="paymentData.titular" placeholder="Titular" class="form-control mb-2">
                <label>Fecha Emisión:</label>
                <input v-model="paymentData.fecha_emision" type="date" class="form-control">
            </div>

            <div v-if="selectedMethod === 'deposito'">
                <input v-model="paymentData.cuenta" placeholder="Nro Cuenta Destino" class="form-control mb-2">
                <input v-model="paymentData.banco" placeholder="Banco Emisor" class="form-control mb-2">
                <input v-model="paymentData.referencia" placeholder="Nro Depósito / Voucher" class="form-control">
            </div>

            <div v-if="selectedMethod === 'cripto'">
                <input v-model="paymentData.billetera" placeholder="Dirección Billetera Emisora" class="form-control mb-2">
                <input v-model="paymentData.hash" placeholder="Hash de Transacción (TXID)" class="form-control">
            </div>

            <div v-if="selectedMethod === 'efectivo'">
                <p class="alert-info"><i class="fa-solid fa-info-circle"></i> Debes dirigirte a taquilla para validar el pago.</p>
            </div>
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn-cancel" @click="close">Cancelar</button>
        <button class="btn-pay" :disabled="processing || !isValid" @click="submitPayment">
            <i v-if="processing" class="fa-solid fa-spinner fa-spin"></i>
            {{ processing ? 'Procesando...' : 'Pagar Ahora' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, reactive, onMounted } from 'vue';

const props = defineProps({
  isOpen: Boolean,
  amount: Number,
  allowMiles: Boolean 
});

const emit = defineEmits(['close', 'payment-success']);

const processing = ref(false);
const selectedCurrency = ref({ code: 'USD', value: 1 });
const selectedMethod = ref(null);
const paymentData = reactive({});
const rates = ref([]);

const availableMethods = computed(() => {
    const methods = [
        { id: 'zelle', label: 'Zelle', icon: 'fa-solid fa-z' },
        { id: 'credito', label: 'T. Crédito', icon: 'fa-regular fa-credit-card' },
        { id: 'debito', label: 'T. Débito', icon: 'fa-solid fa-credit-card' },
        { id: 'movil', label: 'Pago Móvil', icon: 'fa-solid fa-mobile-screen' },
        { id: 'transferencia', label: 'Transferencia', icon: 'fa-solid fa-building-columns' },
        { id: 'deposito', label: 'Depósito', icon: 'fa-solid fa-money-check' },
        { id: 'cheque', label: 'Cheque', icon: 'fa-solid fa-money-check-dollar' },
        { id: 'cripto', label: 'Cripto', icon: 'fa-brands fa-bitcoin' },
        { id: 'efectivo', label: 'Efectivo', icon: 'fa-solid fa-money-bill' },
    ];
    if (props.allowMiles) {
        methods.push({ id: 'millas', label: 'Millas', icon: 'fa-solid fa-plane' });
    }
    return methods;
});

const isValid = computed(() => {
    if (!selectedMethod.value) return false;
    const d = paymentData;
    
    switch (selectedMethod.value) {
        case 'zelle': return d.correo && d.referencia;
        case 'credito': 
        case 'debito': return d.numero && d.cvv && d.vencimiento && d.banco && d.titular;
        case 'movil': return d.referencia;
        case 'transferencia': return d.cuenta && d.referencia;
        case 'deposito': return d.cuenta && d.banco && d.referencia;
        case 'cheque': return d.numero_cheque && d.cuenta && d.banco && d.fecha_emision;
        case 'cripto': return d.billetera && d.hash;
        case 'efectivo': return true;
        default: return false;
    }
});

const resetDataAndSelect = (methodId) => {
    selectedMethod.value = methodId;
    // Limpiar objeto reactivo para evitar datos cruzados
    Object.keys(paymentData).forEach(key => delete paymentData[key]);
};

const loadRates = async () => {
    // Tasas hardcodeadas que coinciden con tus inserts de BD
    rates.value = [
        { code: 'USD', value: 1.00 },
        { code: 'BS', value: 274.00 }, // OJO: Asegúrate que coincida con lo insertado en BD
        { code: 'EUR', value: 0.85 },
        { code: 'YEN', value: 156.20 },
        { code: 'GBP', value: 0.74 }
    ];
    selectedCurrency.value = rates.value[0];
};

const submitPayment = async () => {
    processing.value = true;
    try {
        const datosFinales = { ...paymentData };
        // Corrección formato fecha YYYY-MM a YYYY-MM-01 (Postgres date)
        if (datosFinales.vencimiento && datosFinales.vencimiento.length === 7) {
            datosFinales.vencimiento = datosFinales.vencimiento + '-01';
        }

        const payload = {
            moneda: selectedCurrency.value.code,
            monto_calculado: props.amount * selectedCurrency.value.value,
            metodo: selectedMethod.value, // Se enviará 'movil', 'cripto', etc.
            datos: datosFinales
        };
        emit('payment-success', payload);
    } catch (e) {
        console.error(e);
    } finally {
        processing.value = false;
    }
};

const close = () => {
    selectedMethod.value = null;
    emit('close');
};

onMounted(() => {
    loadRates();
});
</script>

<style scoped>
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 999; }
.modal-card { background: white; width: 95%; max-width: 600px; border-radius: 12px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto; }
.modal-header { background: #1e293b; color: white; padding: 15px 20px; display: flex; justify-content: space-between; align-items: center; }
.close-btn { background: none; border: none; color: white; font-size: 1.5rem; cursor: pointer; }
.modal-body { padding: 20px; }

.amount-display { text-align: center; margin-bottom: 20px; background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; }
.amount-value { font-size: 2rem; font-weight: 800; color: #3b82f6; }

.methods-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
.method-btn { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 5px; padding: 10px; border: 1px solid #cbd5e1; background: white; border-radius: 8px; cursor: pointer; transition: all 0.2s; font-size: 0.8rem; height: 80px; }
.method-btn:hover { background: #f1f5f9; }
.method-btn.active { border-color: #3b82f6; background: #eff6ff; color: #3b82f6; font-weight: bold; }

.form-control { width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; }
.row-half { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
.dynamic-form { background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; }

.modal-footer { padding: 15px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; }
.btn-pay { background: #10b981; color: white; border: none; padding: 10px 20px; border-radius: 6px; font-weight: bold; cursor: pointer; }
.btn-pay:disabled { background: #94a3b8; cursor: not-allowed; }
.btn-cancel { background: transparent; border: 1px solid #cbd5e1; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
</style>