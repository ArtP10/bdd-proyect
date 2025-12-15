import { createRouter, createWebHistory } from 'vue-router';
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';
import AdminDashboard from '@/views/admin/AdminDashboard.vue';
import ProviderAirlineDashboard from '@/views/provider/ProviderAirlineDashboard.vue';

// IMPORTANTE: Asegúrate de que este nombre de archivo coincida con el que creaste.
// Si copiaste mi código anterior, el archivo se llamaba 'AdminPromociones.vue'.
// Si lo llamaste 'AdminGestionPromociones.vue', déjalo así.
import Promotions from '@/views/admin/AdminGestionPromociones.vue'; 

const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path:'/login',
            name:'login',
            component: Login
        },
        {
            path:'/client/register/',
            name:'client-register',
            component:SelfRegisterClient
        },
        {
            path:'/client/dashboard',
            name:'client-dashboard',
            component:ClientDashboard
        },
        {
            path:'/admin/dashboard',
            name:'admin-dashboard',
            component:AdminDashboard
        },
        {
            path:'/providers/airlines/dashboard',
            name:'providers-airlines-dashboard',
            component:ProviderAirlineDashboard
        },
        
        // --- RUTAS DE PROMOCIONES ---
        // Solo necesitas esta ruta. El "Builder" ahora es un modal dentro de ella.
        {
            path:'/admin/promotions',
            name:'admin-promotions',
            component:Promotions
        }
        // SE ELIMINÓ LA RUTA '/promotions/build-promotion/:prom_codigo' PORQUE YA NO ES NECESARIA
    ]
})

export default router;