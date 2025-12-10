import { createRouter, createWebHistory } from 'vue-router';
import Login from '@/views/general/Login.vue';
import SelfRegisterClient from '@/views/client/SelfRegisterClient.vue';
import ClientDashboard from '@/views/client/ClientDashboard.vue';


const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes: [
        {
            path:'/login',
            name:'login',
            component: Login
        },
        {
            path:'/clients/register/',
            name:'clients-register',
            component:SelfRegisterClient
        },
        {
            path:'/clients/dashboard',
            name:'clients-dashboard',
            component:ClientDashboard
        }
    ]
})

export default router;