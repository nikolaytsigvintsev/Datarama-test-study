// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"


let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
    // defp put_user_token(conn, _) do
    //   if current_user = conn.assigns[:current_user] do
    //     token = Phoenix.Token.sign(conn, "user socket", current_user.id)
    //     assign(conn, :user_token, token)
    //   else
    //     conn
    //   end
    // end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
// Normal Socket setup code ...

socket.connect()
socket.onError(function() {
      console.log("Socket error !");
      window.location.href = "/";
    });

const createSocket = ( topicId ) => {
  // Now that you are connected, you can join channels with a topic:
  let channel = socket.channel("comments:" + topicId , {})
  channel.join()
    // .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("ok", resp => {   console.log( resp );renderComments( resp.comments ); })
    .receive("error", resp => { console.log("Unable to join", resp) })

    document.querySelector('#add_point').addEventListener('click', function() {
      const content = document.querySelector('#text_comments').value;
      channel.push( 'comments:add' , { content: content } )
      document.querySelector('#text_comments').value = "";
    });

  channel.on(`comments:${ topicId }:new` , renderComment )
  channel.on(`comments:${ topicId }:delete` , resp => { renderComments( resp.comments );} )

   function renderComments( comments ){
      const renderedComments = comments.map( comment => {
        return commentTemplate( comment );
      });

      document.querySelector( '.collection').innerHTML = renderedComments.join('');


    // Add script for event buttons Delete
       var btn = document.querySelectorAll('a.btn.btn-delete');
       btn.forEach(function(button, index) {
         // console.log(btn[index].id)
          button.addEventListener('click', function() {
             console.log(btn[index].id);
             channel.push( 'comments:delete' , { id: btn[index].id } )
          });
      });
  }

  function renderComment( event ){
        console.log( event );
        const renderedComment = commentTemplate( event.content )
        document.querySelector( '.collection').innerHTML += renderedComment;

  }
// ${ comment.id }
  function commentTemplate( comment ){
    return `
        <li class="collection-item">
        <div class="row">
          <div class="col s8 left-align">${ comment.content }</div>
          <div class="col s2"><a class="left-right waves-effect waves-light btn btn-delete red lighten-1" id="${ comment.id }">Delete</a></div>
        </div>
        </li>
    `
  }

//=====================================================================
//  Uploads section for upload file with socket
//=====================================================================

  let channel_uploads = socket.channel("uploads:" + topicId, {})
  channel_uploads.join()
    .receive("ok", resp => {   console.log("Joined successfully", renderUploads( resp.images ) ) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  //-------------- Incomming events ---------------------------
  //channel.on(`uploads:${ topicId }:new` , renderUpload )
  //-----------------------------------------------------------

  let button = document.getElementById("upload_files")
    button.addEventListener("click", (e) => {
      e.preventDefault();
      onUpload(channel_uploads);
    }, false)

   function onUpload(channel_uploads) {
        let fileInput = document.getElementById("files_name")
        console.log("fileInput", fileInput)

        let arrFiles = fileInput.files
              console.log("arrFiles", arrFiles)
        Object.keys(arrFiles).forEach(function(key){
                      // console.log(arrFiles[key])
                let reader = new FileReader()
                reader.addEventListener("load", function(){
                  let payload = {binary: reader.result.split(",", 2)[1], filename: arrFiles[key].name}
                  channel_uploads.push("upload:file", payload)
                  .receive(
                  "ok", (reply) => {
                    console.log("got reply", renderUpload( reply.contents ) )
                  }
                 )
                }, false)
            reader.readAsDataURL(arrFiles[key])
        })
    }
  //=====================================================================
  function renderUploads( uploads ){
     console.log( uploads );
     const renderedUploads = uploads.map( content => {
           console.log( content );
           return uploadTemplate( content );
    });
    document.querySelector( '#files_name').value = ''
    document.querySelector( '#table_files').innerHTML = renderedUploads.join('');
    M.Materialbox.init( document.querySelectorAll('.materialboxed') , 'inDuration');
  }

  function renderUpload( content ){
        console.log( content );
        const renderedUpload = uploadTemplate( content )
        document.querySelector( '#table_files').innerHTML += renderedUpload;

  }

  function uploadTemplate( content ){
    var mime = ""
    switch(content.file_type){
      case 'image/jpeg':
      case 'image/png':
        mime = `<img class='materialboxed' width='250' src="uploads/${content.name_uuid}">`
      break;
      case 'video/mp4':
        mime = `<video class="responsive-video" width='250' controls><source src="uploads/${content.name_uuid}" type="video/mp4"></video>`
      break;
    }
    return `
     <tr>
       <td>${mime}</td>
       <td>${content.name_orign}</td>
       <td>${content.file_type}</td>
       <td>${content.updated_at}</td>
       <td>
          <div class="col s2"><a class="left-right waves-effect waves-light btn btn-delete red lighten-1" id="${content.id }">Delete</a></div>
      </td>
     </tr>
    `
  }
}
window.createSocket = createSocket;


// export default socket
