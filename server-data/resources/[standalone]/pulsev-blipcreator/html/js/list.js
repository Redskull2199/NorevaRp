import {el} from './dialogs.js';
import {spriteImage,colorById} from './catalog.js';
export function renderList(root,state,onAction){
  const {items=[],total=items.length,page=1,pages=1,pending=false}=state;
  const table=el('table',{class:'blip-table'},el('thead',{},el('tr',{},...['KONUM / BLIP','KATEGORİ','KOORDİNATLAR','DURUM','İŞLEMLER'].map(t=>el('th',{text:t})))));
  const body=el('tbody');table.append(body);
  body.append(...items.map(record=>{
    const icon=el('span',{class:'row-icon'},spriteImage(record.sprite));icon.style.borderColor=`${colorById(record.color)?.hex||'#58ceb2'}55`;
    return el('tr',{'data-id':record.id},
      el('td',{},el('div',{class:'identity'},icon,el('div',{},el('strong',{text:record.name}),el('span',{class:'subline',text:`#${String(record.id).padStart(3,'0')} · Simge ${record.sprite}`})))),
      el('td',{},el('span',{class:'category-pill',text:record.category})),
      el('td',{class:'coordinates',text:`${Number(record.x).toFixed(1)} / ${Number(record.y).toFixed(1)} / ${Number(record.z).toFixed(1)}`}),
      el('td',{},el('button',{class:`status ${record.enabled?'active':''}`,disabled:pending,'aria-label':`${record.name} durumunu değiştir`,onclick:()=>onAction('status',record)},el('i'),el('span',{text:record.enabled?'Aktif':'Pasif'}))),
      el('td',{},el('div',{class:'row-actions'},el('button',{class:'icon-button',disabled:pending,title:'Konuma ışınlan','aria-label':`${record.name} konumuna ışınlan`,text:'↗',onclick:()=>onAction('teleport',record)}),el('button',{class:'icon-button',disabled:pending,title:'Düzenle','aria-label':`${record.name} düzenle`,text:'✎',onclick:()=>onAction('edit',record)}),el('button',{class:'icon-button delete-action',disabled:pending,title:'Sil','aria-label':`${record.name} sil`,text:'×',onclick:()=>onAction('delete',record)}))));
  }));
  const empty=!items.length?el('div',{class:'empty-state'},el('span',{class:'empty-mark',text:'⌖'}),el('h3',{text:'Burada henüz bir iz yok'}),el('p',{text:'Aramanızı değiştirin veya yeni bir blip oluşturun.'})):null;
  root.replaceChildren(el('div',{class:'table-scroll'},table,empty),el('footer',{class:'list-footer'},el('span',{text:`${total} kayıttan ${total?((page-1)*25+1):0}–${Math.min(page*25,total)} gösteriliyor`}),el('div',{class:'pager'},el('button',{'aria-label':'Önceki sayfa',disabled:page<=1,text:'←',onclick:()=>onAction('page',page-1)}),el('span',{text:`${page} / ${pages}`}),el('button',{'aria-label':'Sonraki sayfa',disabled:page>=pages,text:'→',onclick:()=>onAction('page',page+1)}))));
}
