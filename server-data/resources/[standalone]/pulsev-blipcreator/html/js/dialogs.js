export function el(tag, attrs = {}, ...children) {
  const node = document.createElement(tag);
  for (const [key,value] of Object.entries(attrs)) {
    if (key === 'class') node.className = value;
    else if (key === 'text') node.textContent = value;
    else if (key.startsWith('on')) node.addEventListener(key.slice(2).toLowerCase(), value);
    else if (value !== undefined && value !== false) node.setAttribute(key, value === true ? '' : value);
  }
  children.flat().forEach(child => { if (child) node.append(child); });
  return node;
}
const stack = [];
export function openDialog({title, subtitle, content, className = '', onClose}) {
  const previous = document.activeElement;
  const close = () => { const index = stack.indexOf(entry); if(index<0)return; stack.splice(index,1); shade.remove(); previous?.focus(); onClose?.(); };
  const panel = el('section',{class:`modal ${className}`,role:'dialog','aria-modal':'true','aria-label':title,tabindex:'-1'},
    el('header',{class:'modal-heading'},el('div',{},el('h2',{text:title}),subtitle&&el('p',{text:subtitle})),el('button',{class:'icon-button','aria-label':'Pencereyi kapat',text:'×',onclick:close})),content);
  const shade = el('div',{class:'dialog-shade'},panel);
  const entry={close,panel}; stack.push(entry); document.querySelector('#dialogs').append(shade);
  panel.addEventListener('keydown',event=>{
    if(event.key!=='Tab')return;
    const focusable=[...panel.querySelectorAll('button,input,select,textarea,[tabindex="0"]')].filter(n=>!n.disabled&&!n.hidden);
    const first=focusable[0],last=focusable.at(-1);
    if(event.shiftKey&&(document.activeElement===first||document.activeElement===panel)){event.preventDefault();last?.focus();}
    else if(!event.shiftKey&&document.activeElement===last){event.preventDefault();first?.focus();}
  });
  queueMicrotask(()=> (panel.querySelector('input,button')||panel).focus());
  return {close,panel};
}
export function closeTopDialog(){ if(!stack.length)return false;stack.at(-1).close();return true; }
export function hasDialog(){return stack.length>0;}
export function confirmDialog({title='Emin misiniz?',message='',confirmText='Onayla',danger=false}){
  return new Promise(resolve=>{
    let confirmed=false;
    const body=el('div',{class:'confirm-body'},el('p',{text:message}));
    const dialog=openDialog({title,content:body,className:'confirm-dialog',onClose:()=>resolve(confirmed)});
    body.append(el('footer',{class:'dialog-actions'},el('button',{class:'button secondary',text:'Vazgeç',onclick:dialog.close}),el('button',{class:`button ${danger?'danger':'primary'}`,text:confirmText,onclick:()=>{confirmed=true;dialog.close();}})));
  });
}
