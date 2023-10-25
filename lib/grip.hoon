/-  *hood
|%
+$  action
  $%
  [%create-ticket =ticket]
  [%set-enabled enabled=?]
  ==
::
+$  ticket-type 
  $?  %request   :: feature request
      %support   :: support request
      %report    :: bug report
      %document  :: request for documentation
      %general   :: general feedback
  ==
  ::
+$  ticket
  $:  board=desk
      title=@t
      body=@t
      author=@p
      anon=?
      =app-version
      =ticket-type
      ==
  ::
+$  app-version
  [major=@ud minor=@ud patch=@ud]
  ::
++  agent
  |=  [dev=ship version=app-version ui-path=path]
  ^-  $-(agent:gall agent:gall)
  |^  agent
  ::
  +$  state-0  $:  %0  
                  auto-enabled=?
                ==
  +$  card  card:agent:gall
  ++  agent
    |=  inner=agent:gall
    =|  state-0
    =*  state  -
    ^-  agent:gall
    |_  =bowl:gall
    +*  this  .
        ag    ~(. inner bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      =.  auto-enabled  %.n
      =^  cards  inner  on-init:ag
      [cards this]
    ::
    ++  on-save  
    !>([[%grip state] on-save:ag])
    ::
    ++  on-load  
    |=  val=vase
    ^-  (quip card _this)
    ?.  ?=([[%grip *] *] q.val)
      =.  auto-enabled  %.n
      =^  cards  inner  (on-load:ag val)
      [cards this]
      ::
    =+  !<([[%grip old=state-0] =vase] val)
    =.  state  old
    =^  cards  inner  (on-load:ag vase)
    [cards this]
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      |^
      ?+  mark  [inner-cards this]
      %grip
        ?>  =(src.bowl our.bowl)
        =/  pok  !<(action vase)
        ?-  -.pok
          %create-ticket 
            =.  board.ticket.pok         dap.bowl
            =.  app-version.ticket.pok  *app-version
            =.  author.ticket.pok       ?.(anon.ticket.pok our.bowl ~zod)
          :_  this
          :~  (send-to-pharos dev ticket.pok)
          ==
          ::
          %set-enabled
          `this(auto-enabled +.pok)
        ==
      %handle-http-request
      ?>  =(src.bowl our.bowl)
      =/  req  !<([eyre-id=@ta =inbound-request:eyre] vase)
      =/  site  (parse-request-line url.request.inbound-request.req)
      =+  send=(cury simple-payload eyre-id.req)
      =*  dump   [inner-cards this]
        ?+    method.request.inbound-request.req  dump
          ::
            %'GET'
            ?.  =(ui-path `(list @ta)`(swag [0 2] site))  dump
              ::  fallback: forward poke to wrapped agent core
            =/  url       (to-tape-url (welp ui-path /new-ticket))
            =/  sett-url  (to-tape-url (welp site /settings))
            =.  site      (oust [0 2] site)  :: now we know this isn't ~
            ?~  site  dump
            ?+  site  dump
            ::
            [%report ~]
            :_  this
            %-  manx-payload
            [eyre-id.req 200 ~ (home url sett-url)]
            ::
            [%report %settings ~]
            :_  this
            %-  manx-payload
            [eyre-id.req [200 ~ (home-setting =(auto-enabled %.y))]]
            ==
          ::
           %'POST'
            ?.  =(ui-path (snip site))  dump
            =/  back-url=tape  +:(to-tape-url (welp :~(~...) +.ui-path))
            =.  site  (oust [0 2] site)
            ?~  site  dump                     
            ?+  site  dump
            ::
            [%new-ticket ~]
              ?~  body.request.inbound-request.req
                :_  this
                %-  send  [405 ~ [%err ~]]
              =/  jon=(unit json)  (de:json:html q.u.body.request.inbound-request.req)
              =/  =ticket  (to-ticket (need jon))
              :_  this
              %+  welp
              %-  send  [302 [%'HX-Refresh' 'true']~ [%redirect (crip back-url)]]
              :~  [%pass /self-poke %agent [our.bowl dap.bowl] %poke %grip !>([%create-ticket ticket])]
              ==
            ::
            [%settings-update ~]
              ?~  body.request.inbound-request.req
                :_  this
                %-  send  [405 ~ [%err ~]]
              =/  =json  (need (de:json:html q.u.body.request.inbound-request.req))
              =.  auto-enabled  ?:  =((auto:dejs json) 'true')  &  |
              =/  url  (crip (weld back-url "/report"))
              :_  this
              %-  send  [302 ~ [%redirect url]]
          ==
        ==
      ==
      ++  to-tape-url
      |=  site=path
      ^-  tape
      (sa:dejs:format (path:enjs:format site))
      ::
      ++  inner-cards
      =^  cards  inner  (on-poke:ag mark vase)
      cards
      --
    ::
    ++  on-watch
    |=  =path
    ^-  (quip card _this)
    `this
    ::
    ++  on-leave
    |=  =path
    ^-  (quip card _this)
    =^  cards  inner  (on-leave:ag path)
    [cards this]
    ::
    ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    (on-peek:ag path)
    ::
    ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+    wire  (on-agent wire sign)
      [%pharos ~]
    ?.  ?=(%poke-ack -.sign)
      (on-agent wire sign)
    ?~  p.sign
      `this
    ~&  ~(ram re [%rose ["  " "" ""] (need p.sign)])
    `this
      [%self-poke ~]
    ?.  ?=(%poke-ack -.sign)
      (on-agent wire sign)
    ?~  p.sign
      `this
    `this
    ==
    ::
    ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
     =^  cards  inner  (on-arvo:ag wire sign-arvo)
    [cards this]
    ::
    ++  on-fail
    |=  [=term =tang]
    ^-  (quip card _this)
    |^
    =/  trace  ~(ram re [%rose ["\\n" "" "--"] tang])
    ?:  =(auto-enabled &) 
      :_  this
      :~  (send-to-pharos dev (on-fail-ticket trace))
      ==
    =^  cards  inner  (on-fail:ag term tang)
    [cards this]
      ::
      ++  on-fail-ticket
      |=  trace=tape
        =/  body-vats   %-  crip  
                        %+  weld  trace  vats
        ^-  ticket 
        :*
            desk=dap.bowl
            title='on-fail'
            body=body-vats
            author=our.bowl
            anon=|
            app-version=*app-version
            =%report 
        ==
      ::vats need proper parcing to body msg 
      ++  vats 
        ^-  tape
        =/  desks              .^((set desk) %cd /(scot %p our.bowl)//(scot %da now.bowl))
        =/  deks=(list desk)   ~(tap in desks)
        =/  vat
            %+  turn  deks 
            |=(a=desk (flop (report-vat (report-prep our.bowl now.bowl) our.bowl now.bowl a |)))
        ~(ram re [%rose ["\\n" "" ""] (zing vat)])
    --
  --
::
++  send-to-pharos
  |=  [=ship =ticket]
  ^-  card:agent:gall
  ::~&  ticket
  :*  %pass
      /pharos
      %agent
      [ship %pharos]
      %poke
      %pharos-action
      !>([%create-ticket :*(board.ticket title.ticket body.ticket author.ticket anon.ticket app-version.ticket `ticket-type`ticket-type.ticket)])
  ==
::
++  to-ticket 
|=  =json
^-  ticket 
=/  val=[title=@t body=@t tt=@t anon=@t]  (json-ticket:dejs json)
=/  tt  (tt-check tt.val)
:*  
    desk=*@tas
    title=title.val
    body=body.val
    author=~zod
    anon=?~(anon.val | &)
    app-version=*app-version
    ticket-type=tt
==
::
  ++  tt-check 
  |=  i=@t
  %-  ticket-type  i
  ::
  ++  dejs
  =,  dejs:format 
  |%  
  ++  json-ticket
  %-  ou
  :~  [%title (un so)]
      [%body (un so)]
      [%ticket-type (un so)]
      [%anon (uf '' so)]
  ==
  ++  auto
  %-  ou
  :~  [%auto (un so)]
  ==
  --
::
::  server
::
+$  header   [key=@t value=@t]
+$  headers  (list header)
::
++  parse-request-line
  |=  url=@t
  ^-  (list @t)
  =/  req-line=[[ext=(unit @ta) site=(list @t)] args=(list [@t @t])]  
  %+  fall  (rush url ;~(plug apat:de-purl:html yque:de-purl:html)) 
  [[~ ~] ~]
  site.req-line
::
++  manx-payload
|=  [eyre-id=@ta http-status=@ud =headers =manx]
%-  give-simple-payload 
:*  eyre-id 
  :-  http-status
      ['content-type'^'text/html']~ 
`(as-octt:mimes:html (en-xml:html manx))
==
::
++  simple-payload
|=  [eyre-id=@ta http-status=@ud =headers resource=[type=@tas data=@]]
=/  type  (?(%redirect %err) type.resource)
%-  give-simple-payload 
:-  eyre-id
?-  type
%redirect 
  :_  ~
  :-  http-status
  (weld headers ['location'^data.resource]~)
%err
  :_  (some (as-octs:mimes:html '<h1>405 Method Not Allowed</h1>'))
  :-  http-status
  (weld headers ['content-type'^'text/html']~)
==
::
++  give-simple-payload
  |=  [eyre-id=@ta hed=response-header:http dat=(unit octs)]
  ^-  (list card)
  :~  [%give %fact ~[/http-response/[eyre-id]] %http-response-header !>(hed)]
      [%give %fact ~[/http-response/[eyre-id]] %http-response-data !>(dat)]
      [%give %kick ~[/http-response/[eyre-id]] ~]
  ==
::
++  page
  |=  kid=manx
  ^-  manx
  ;html
    ;head
      ;title: Ticket
      ;meta(charset "utf-8");
      ;script
        =crossorigin  "anonymous"
        =integrity    "sha384-aOxz9UdWG0yBiyrTwPeMibmaoq07/d3a96GCbb9x60f3mOt5zwkjdbcHFnKH8qls"
        =src          "https://unpkg.com/htmx.org@1.9.0";
      ;script
        =crossorigin  "anonymous"
        =integrity    "sha384-nRnAvEUI7N/XvvowiMiq7oEI04gOXMCqD3Bidvedw+YNbj7zTQACPlRI3Jt3vYM4"
        =src          "https://unpkg.com/htmx.org@1.9.0/dist/ext/json-enc.js";
      ;link
        =rel          "stylesheet"
        =crossorigin  "anonymous"
        =integrity    "sha384-Kh+o8x578oGal2nue9zyjl2GP9iGiZ535uZ3CxB3mZf3DcIjovs4J1joi2p+uK18"
        =href         "https://unpkg.com/@fontsource/lora@5.0.8/index.css";
        ;script:  htmx.logAll();
      ;style: {style}
    ==
    ;body(hx-ext "json-enc,include-vals")
      ;+  kid
    ==
  ==
::
++  home
|=  [path=tape sett-path=tape]
  %-  page
  ;div.page
  ;button.set(hx-get sett-path, hx-swap "outerHTML"): Settings
  ;div.main
    ;h1: Support ticket form
    ;div.form
    ;form
        ;label.check(for "anon"): Remain anonymous?
          ;input(type "checkbox", name "anon", value "true", defaultvalue "false");
        ;h3: By remaining anonymous your @p wont be shared with developer.
        ;h3: By adding your @p developer may be able to provide you more detailed support.
        ;label(for "ticket-type"): How can we help you?
        ;select(name "ticket-type")
          ;option(value "request"):  Feature ideas
          ;option(value "support"):  Support request
          ;option(value "report"):   Report bug
          ;option(value "document"): Request to provide documetation
          ;option(value "general"):  Leave feedback
          ==
        ;label(for "title"): Describe the problem
          ;input(type "text", name "title", required "");
        ;label(for "body"): Additional details
          ;textarea(type "text", name "body", required "", minlength "3");
        ;button.submit(type "submit", hx-post path, hx-target "body", hx-push-url "true", hx-swap "outerHTML", hx-push-url "true"): submit
      ==
    ==
  ==
  ==
++  home-setting
|=  auto=?
  %-  page
  ;div.page
        ;form.settings
        ;button.exit: X
        ;h2: This app supports automatic crush report
        ;+  ?:  auto
          ;input(type "hidden", name "auto", value "false");
          ;input(type "hidden", name "auto", value "true");
        ;button.set(hx-post "./settings-update", hx-target "body", hx-push-url "true")
            ;+  ?:  auto
              ;/  "disable" 
            ;/  "enable"
        ==
    ==
  ==
::
++  style
  ^~
  %-  trip
  '''
  :root {
  --measure: 70ch;
  }
  .page{
  margin:           auto;
  width:            50%;
  padding:          10px;
  color:            black;
  font-family:      Lora, serif;
  }
  .main {
  position:         absolute;
  top:              50%;
  left:             50%;
  transform:        translate(-50%, -50%);
  border:           8px solid #197489;
  padding:          10px;
  padding-top:      2px;
  background-color: white;
  }
  .settings{
  position:         absolute;
  top:              50%;
  left:             50%;
  transform:        translate(-50%, -50%);
  border:           10px solid #78c6ce;
  padding:          10px;
  z-index:          3;
  background-color: white;
  color:            black;
  text-align:       center;
  }
  h1{
  font-size:        24px;
  font-weight:      bold;
  font-family:      Lora, serif;
  color:            white;
  text-align:       center;
  width:            100%;
  padding:          auto;
  padding-bottom:   10px;
  padding-top:      10px;
  margin-top:       0;
  margin-bottom:    5px;
  display:          block;
  background:       #2AAFCE;
  }
  h2{
  font-size:        16px;
  }
  h3{
  color:            #2AAFCE;
  font-size:        11px;
  width:            100%;
  margin:           auto;
  }
  label {
  width:            100%;
  margin:           3px;
  font-size:        16px;
  display:          inline-block;
  }
  input[type=text], textarea, select{
  width:            100%;
  padding:          12px;
  margin:           3px;
  border:           3px solid #197489;
  resize:           vertical;
  font-family:      monospace;
  }
  input[type=checkbox]{
  height:           20px;
  float:            right;
  width:            20px;
  accent-color:     #2AAFCE;
  }
  .check{
  width:            50%;
  margin:           3px;
  display:          inline-block;
  }
  textarea{
  resize:           none;
  height:           150px;
  }
  input:focus [type=checkbox], textarea, select, [type=text]{
  outline:          none;
  }
  button{
  font-family:      monospace;
  font-size:        90%;
  display:          block;
  margin:           auto;
  width:            auto;
  padding:          5px;
  border:           2px solid #197489;
  border-radius:    6px;
  background:       #368C96;
  color:            white;
  }
  button:hover{
  cursor:           pointer;
  }
  .submit{
  float:            right;
  margin-top:       10px;
  }
  .set{
  float: right;
  }
  .exit{
  width:         auto;
  margin:        auto;
  button-radius: 1px;
  margin-left:   6px;
  margin-bottom: 6px;
  padding:       5px;
  padding-right: 8px;
  padding-left:  8px;
  float:         right;
  font-size:     10px;
  }
  '''
--
--