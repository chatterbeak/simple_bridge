%% vim: ts=4 sw=4 et
-module(simple_bridge_callout_sample).
-behaviour(simple_bridge_callout).
-export([run/1,
        ws_init/1,
        ws_message/2,
        ws_info/2,
        ws_terminate/2]).


run(Bridge) ->
    Bridge2 = Bridge:set_response_data(body(Bridge)),
    Bridge2:build_response().

ws_init(_Bridge) ->
    %erlang:send_after(1000, self(), "START"),
    ok.

ws_message({text, <<"frag">>}, _Bridge) ->
    Reply = [{text, [Msg," "]} || Msg <- ["A","spoon","full","of","sugar"]],
    {reply, Reply};
ws_message({text, Data}, _Bridge) ->
    %Reply = io_lib:format("~s", [Data]),
    {reply, {text, Data}};
ws_message({binary, Data}, _Bridge) ->
    {reply, {binary, Data}}.

ws_info(Data, _Bridge) ->
    Reply = {text, io_lib:format("~s", [Data])},
    {reply, Reply}.

ws_terminate(_Reason, _Bridge) ->
    ok.


%%% HTML BODY AND DRAWING TESTING THE BRIDGE CAPABILITIES

welcome() ->
    "Welcome to the Simple Bridge Websocket test.<br />Send <b>frag</b> to have the server send frames in fragments to the client.<br />Send <b>frag2</b> to send a fragmented message to the server from the client.".

body(Bridge) ->
    [
    <<"<html>
    <head>
        <title>Hello from Simple Bridge!</title>
        <script src='//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'></script>
        <script src='/js/websocket.js'></script>
    </head>
    <body>
        <h1>Hello from Simple Bridge!</h1>">>,
        connection_info(Bridge),
        <<"<div id='header'>
          <div id='status'></div>
        </div>


        <div id='navigation'>
          <p id='connecting'>
            <input type='text' id='server' value='ws://localhost:8000/'></input>
            <button type='button' onclick='toggle_connection()'>(re)connect websocket</button>
          </p>
          <div id='connected'>                                
            <p>
              <input type='text' id='send_txt' value=''></input>
              <button type='button' onclick='sendTxt();'>send</button>
            </p>
          </div>

          <div id='content'>                                                
            <button id='clear' onclick='clearScreen()' >Clear text</button>
            <div id='output'></div>
          </div>

        </div>
      </body>
    </html>">>
    ].

connection_info(Bridge) ->
    Fields = [socket, protocol, request_method, uri, path, headers, query_params, post_params, peer_ip, protocol_version],
    [
        <<"<table>">>,
        [draw_connection_info(Field, Bridge) || Field <- Fields],
        <<"</table>">>
    ].

draw_connection_info(Field, Bridge) ->
    io_lib:format("<tr><td>~p</td><td><pre>~p</pre></td></tr>",[Field, sbw:Field(Bridge)]).

