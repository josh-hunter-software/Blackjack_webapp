$(document).ready(function() {
  player_hits();
  player_stays();
  dealer_hit();
});

function player_hits() {
   $(document).on("click", "form#hit_form input", function() {

    alert("You chose to hit!");

    $.ajax({
      type: 'POST',
      url: '/game/player/hit'    
    }).done(function(msg) {
      $('#game').replaceWith(msg)
    }); 
    return false; 
  });
}

function player_stays() {
   $(document).on("click", "form#stay_form input", function() {

    alert("You chose to stay!");

    $.ajax({
      type: 'POST',
      url: '/game/player/stay'    
    }).done(function(msg) {
      $('#game').replaceWith(msg)
    }); 
    return false; 
  });
}


function dealer_hit() {
   $(document).on("click", "form#dealer_hit input", function() {

    alert("The dealer chose to hit");

    $.ajax({
      type: 'POST',
      url: '/game/dealer/hit'    
    }).done(function(msg) {
      $('#game').replaceWith(msg)
    }); 
    return false; 
  });
}