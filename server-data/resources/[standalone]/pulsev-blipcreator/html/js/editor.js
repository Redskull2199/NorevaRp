import {el} from './dialogs.js';
import {spriteImage,colorById} from './catalog.js';
const numeric=new Set(['sprite','color','scale','alpha','display','rotation','x','y','z','map_category']);
export function createEditor(root,{onSave,onPosition,onPreview,onChooseSprite,onChooseColor,onClose,onMinimize}){
  let original='',draft={},options={},previewTimer;let isOpen=false;const controls={},feedback={};
  function field(name,label,type='text',attrs={}){
    const input=el(type==='textarea'?'textarea':'input',{name,type:type==='textarea'?undefined:type,...attrs});controls[name]=input;
    const error=el('small',{class:'field-error','data-error':name});feedback[name]=error;
    input.addEventListener('input',()=>{feedback[name].textContent='';refreshPreview();});
    const counter=['name','category','note'].includes(name)?el('small',{class:'character-count'}):null;
    if(counter){const update=()=>{const limit=options.Limits?.[name]?.maxChars||({name:64,category:48,note:512})[name];counter.textContent=`${[...input.value].length} / ${limit}`;};input.addEventListener('input',update);input.updateCounter=update;}
    return el('label',{class:`field field-${name}`},el('span',{class:'field-label'},el('span',{text:label}),counter),input,error);
  }
  function select(name,label,choices){const input=el('select',{name},...choices.map(([value,text])=>el('option',{value,text})));controls[name]=input;input.addEventListener('change',refreshPreview);const error=el('small',{class:'field-error'});feedback[name]=error;return el('label',{class:'field'},el('span',{text:label}),input,error);}
  function check(name,label){const input=el('input',{name,type:'checkbox'});controls[name]=input;input.addEventListener('change',refreshPreview);return el('label',{class:'check-field'},input,el('span',{text:label}));}
  const previewIcon=el('div',{class:'preview-icon'}),previewName=el('strong'),previewMeta=el('span'),spriteButton=el('button',{type:'button',class:'choice-button','data-action':'choose-sprite',onclick:()=>onChooseSprite(getDraft().sprite,setSprite)}),colorButton=el('button',{type:'button',class:'choice-button','data-action':'choose-color',onclick:()=>onChooseColor(getDraft().color,setColor)});
  controls.sprite=el('input',{type:'hidden',name:'sprite'});controls.color=el('input',{type:'hidden',name:'color'});
  const conflict=el('div',{class:'inline-alert',role:'alert',hidden:true}),form=el('form',{class:'editor-form',novalidate:true});
  const save=el('button',{class:'button primary',type:'submit',text:'Blip oluştur'}),cancel=el('button',{class:'button secondary',type:'button',text:'Vazgeç',onclick:()=>onClose()});
  const previewCheck=check('live_preview','Oyun içinde canlı önizleme');controls.live_preview.checked=false;
  form.append(conflict,el('div',{class:'editor-scroll'},
    el('div',{class:'section-label',text:'01 / TEMEL BİLGİLER'}),field('name','Blip adı','text',{placeholder:'Örn. Legion Square'}),el('div',{class:'field-row'},field('category','Panel kategorisi'),select('map_category','Harita kategorisi',[[1,'1 · Genel'],[2,'2 · Konum'],[7,'7 · Oyuncu'],[10,'10 · Mülk'],[11,'11 · Özel'],...Array.from({length:243},(_,i)=>[i+12,`${i+12} · Özel kategori`])])),field('note','Yönetici notu','textarea',{rows:2,placeholder:'Yalnızca yöneticiler görebilir…'}),
    el('div',{class:'section-label',text:'02 / HARİTA GÖRÜNÜMÜ'}),el('div',{class:'field-row'},el('label',{class:'field'},el('span',{text:'Simge'}),spriteButton,controls.sprite),el('label',{class:'field'},el('span',{text:'Renk'}),colorButton,controls.color)),
    el('div',{class:'field-row thirds'},field('scale','Boyut','number',{min:.1,max:2,step:.05}),field('alpha','Opaklık','number',{min:0,max:255}),field('rotation','Dönüş °','number',{min:0,max:359})),
    el('div',{class:'field-row'},select('display','Görünürlük',Array.from({length:11},(_,i)=>[i,`${i} · ${i===2?'Harita ve radar':i===0?'Gizli':i===3?'Harita':'GTA görünümü'}`])),el('div',{class:'check-stack'},check('short_range','Yalnızca yakın mesafede'),check('enabled','Blip aktif'))),
    el('div',{class:'section-label coordinate-heading'},el('span',{text:'03 / KONUM'}),el('button',{type:'button',class:'text-button','data-action':'position',text:'⌖ Mevcut konumum',onclick:async()=>{const position=await onPosition();if(position){['x','y','z','rotation'].forEach(k=>{controls[k].value=position[k];});refreshPreview();}}})),
    el('div',{class:'field-row thirds'},field('x','X','number',{step:'any'}),field('y','Y','number',{step:'any'}),field('z','Z','number',{step:'any'})),
    el('div',{class:'preview-card'},previewIcon,el('div',{},previewName,previewMeta)),el('div',{class:'preview-controls'},previewCheck,el('button',{class:'text-button',type:'button','data-action':'minimize',text:'Paneli küçült ↗',onclick:()=>onMinimize()})),el('p',{class:'hint',text:'Simge ve renk görünümü yaklaşık önizlemedir. Son görünümü oyun içinde kontrol edin.'})),
    el('footer',{class:'editor-footer'},cancel,save));
  form.addEventListener('submit',e=>{e.preventDefault();onSave(getDraft());});
  root.append(el('header',{class:'editor-heading'},el('div',{},el('span',{class:'eyebrow',text:'BLIP TASARIMI'}),el('h2',{'data-editor-title':'',text:'Yeni blip'})),el('button',{class:'icon-button','aria-label':'Düzenleyiciyi kapat',text:'×',onclick:()=>onClose()})),form);
  function getDraft(){const result={...draft};for(const [name,input]of Object.entries(controls)){if(name==='live_preview')continue;result[name]=input.type==='checkbox'?input.checked:numeric.has(name)?(input.value.trim()===''?NaN:Number(input.value)):input.value;}return result;}
  function setSprite(id){controls.sprite.value=id;refreshPreview();}
  function setColor(id){controls.color.value=id;refreshPreview();}
  function refreshPreview(){const value=getDraft(),color=colorById(value.color);spriteButton.replaceChildren(spriteImage(value.sprite),el('span',{text:`Simge #${value.sprite}`}),el('span',{text:'↗'}));const swatch=el('span',{class:'swatch'});swatch.style.background=color?.hex||'#fff';colorButton.replaceChildren(swatch,el('span',{text:color?.label||`Renk ${value.color}`}),el('span',{text:'↗'}));previewIcon.replaceChildren(spriteImage(value.sprite));previewIcon.style.background=`${color?.hex||'#58ceb2'}20`;previewName.textContent=value.name||'Yeni blip';previewMeta.textContent=`${value.category||'Genel'} · ${Number(value.scale||0).toFixed(2)} ölçek`;clearTimeout(previewTimer);previewTimer=setTimeout(()=>onPreview(controls.live_preview.checked?value:null),200);}
  return {
    open(value,newOptions={}){draft={...value};options=newOptions;for(const[name,input]of Object.entries(controls)){if(name==='live_preview')continue;if(input.type==='checkbox')input.checked=Boolean(value[name]);else input.value=value[name]??'';input.updateCounter?.();}original=JSON.stringify(getDraft());root.hidden=false;isOpen=true;root.querySelector('[data-editor-title]').textContent=value.id?'Blipi düzenle':'Yeni blip';save.textContent=value.id?'Değişiklikleri kaydet':'Blip oluştur';conflict.hidden=true;this.setFields({});refreshPreview();queueMicrotask(()=>controls.name.focus());},
    getDraft, isDirty(){return original!==JSON.stringify(getDraft());},isOpen(){return isOpen;},
    setFields(errors){for(const [key,node]of Object.entries(feedback)){node.textContent=errors?.[key]||'';controls[key]?.setAttribute('aria-invalid',errors?.[key]?'true':'false');}},
    setConflict(error){conflict.hidden=false;conflict.textContent=typeof error==='string'?error:error?.message||'Kayıt başka bir yönetici tarafından değiştirildi. Listeyi yenileyip tekrar deneyin.';},
    setPending(value){form.querySelectorAll('button,input,select,textarea').forEach(n=>n.disabled=value);},
    close(){clearTimeout(previewTimer);isOpen=false;root.hidden=true;controls.live_preview.checked=false;onPreview(null);},
  };
}
