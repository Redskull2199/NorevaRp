import {el} from './dialogs.js';
export function notify({kind='info',message}){const item=el('div',{class:`toast ${kind}`,role:'status',text:message});document.querySelector('#notifications').append(item);setTimeout(()=>item.remove(),4500);}
