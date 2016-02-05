
import Effects exposing (Never)
import AbacusTrainer exposing( init, effective_update, view )
import StartApp
import Task


app =
  StartApp.start
    { init = init
    , update = effective_update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks


