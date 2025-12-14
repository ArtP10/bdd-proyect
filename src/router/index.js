import { createRouter, createWebHistory } from 'vue-router';
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';
import AdminDashboard from '@/views/admin/AdminDashboard.vue';
import ProviderAirlineDashboard from '@/views/provider/ProviderAirlineDashboard.vue';
// Importamos el componente de Promociones (asumo que está en admin)
import Promotions from '@/views/admin/Promotions.vue'; 
// Importamos el nuevo componente de construcción
import PromotionBuilder from '@/views/admin/PromotionBuilder.vue'; 


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
        {
            path:'/admin/promotions',
            name:'admin-promotions',
            component:Promotions
        },
        {
            // Ruta dinámica que recibe el prom_codigo como parámetro
            path:'/promotions/build-promotion/:prom_codigo', 
            name:'promotion-builder',
            component:PromotionBuilder,
            props: true // Permite que prom_codigo se inyecte como prop si es necesario
        },
    ]
})

export default router;