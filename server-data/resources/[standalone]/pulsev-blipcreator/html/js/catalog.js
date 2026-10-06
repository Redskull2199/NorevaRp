import {el,openDialog} from './dialogs.js';
let activeCatalog={sprites:[],colors:[]};
const turkishAliases=[['hospital','hastane sağlık'],['police','polis karakol'],['garage','garaj otopark'],['airport','havalimanı havaalanı'],['gun','silah'],['shop','mağaza market'],['store','mağaza market'],['bank','banka'],['beach','plaj sahil'],['mechanic','mekanik tamir'],['barber','berber kuaför'],['clothes','kıyafet giyim'],['ammunation','silah'],['restaurant','restoran yemek'],['boat','tekne deniz'],['taxi','taksi'],['car','araç otomobil'],['house','ev mülk'],['property','ev mülk'],['fuel','benzin yakıt'],['gas','benzin yakıt']];
export function setCatalog(catalog){activeCatalog=catalog;}
export function searchSprites(catalog,query='',page=1,pageSize=72){
  const q=query.trim().toLocaleLowerCase('tr-TR');
  const exact=/^\d+$/.test(q)?Number(q):null;
  const matches=catalog.sprites.filter(s=>{if(exact!==null)return s.id===exact;const aliases=turkishAliases.filter(([english])=>s.name.includes(english)).map(([,translated])=>translated);return[s.label,s.name,...(s.aliases||[]),...aliases].join(' ').toLocaleLowerCase('tr-TR').includes(q);});
  const pages=Math.max(1,Math.ceil(matches.length/pageSize));page=Math.max(1,Math.min(pages,Number(page)||1));
  return {items:matches.slice((page-1)*pageSize,page*pageSize),total:matches.length,page,pages};
}
export function spriteImage(id,className='sprite'){const sprite=activeCatalog.sprites.find(s=>s.id===Number(id));return sprite?el('img',{class:className,src:`assets/${sprite.asset}`,alt:'',loading:'lazy'}):el('span',{class:className,text:'◆'});}
export function colorById(id){return activeCatalog.colors.find(c=>c.id===Number(id));}
export function renderSpritePicker(root,selection,onSelect){
  let page=1;const search=el('input',{type:'search',placeholder:'Simge adı veya ID ara…','aria-label':'Simge ara'});
  const grid=el('div',{class:'sprite-grid'}),footer=el('div',{class:'picker-footer'});
  const render=()=>{const result=searchSprites(activeCatalog,search.value,page);page=result.page;grid.replaceChildren(...result.items.map(s=>el('button',{class:`sprite-tile ${s.id===selection?'selected':''}`,title:s.label,'aria-label':s.label,'aria-pressed':s.id===selection,onclick:()=>onSelect(s.id)},spriteImage(s.id),el('span',{text:`#${s.id}`}))));footer.replaceChildren(el('span',{text:`${result.total} simge · ${page} / ${result.pages}`}),el('div',{class:'pager'},el('button',{text:'←',disabled:page===1,'aria-label':'Önceki simge sayfası',onclick:()=>{page--;render();}}),el('button',{text:'→',disabled:page===result.pages,'aria-label':'Sonraki simge sayfası',onclick:()=>{page++;render();}})));};
  search.addEventListener('input',()=>{page=1;render();});root.replaceChildren(el('div',{class:'picker-search'},search),grid,footer);render();
}
export function renderColorPicker(root,selection,onSelect){root.replaceChildren(el('div',{class:'color-grid'},...activeCatalog.colors.map(c=>{const swatch=el('span',{class:'swatch'});swatch.style.background=c.hex;return el('button',{class:`color-tile ${c.id===selection?'selected':''}`,title:`${c.label} · #${c.id}`,'aria-label':`${c.label} ${c.id}`,'aria-pressed':c.id===selection,onclick:()=>onSelect(c.id)},swatch,el('span',{text:`${c.id}`}));})),el('p',{class:'picker-note',text:'Renkler GTA harita paletine göre gösterilir; oyun görünümü farklılık gösterebilir.'}));}
export function chooseSprite(selection,onSelect){const body=el('div',{class:'picker-body'});const dialog=openDialog({title:'Haritada bir iz bırakın',subtitle:'817 yerel simge arasından seçin',content:body,className:'catalog-dialog'});renderSpritePicker(body,selection,id=>{onSelect(id);dialog.close();});}
export function chooseColor(selection,onSelect){const body=el('div',{class:'picker-body'});const dialog=openDialog({title:'Bir renk seçin',subtitle:'GTA harita paleti · 86 renk',content:body,className:'catalog-dialog'});renderColorPicker(body,selection,id=>{onSelect(id);dialog.close();});}
