use crate::messages;
pub async fn tell_treasure() {
    use messages::tutorial_resource::*;

    let mut current_value: i32 = 1;
    let mut receiver = MyTreasureInput::get_dart_signal_receiver(); // GENERATED
    while let Some(_) = receiver.recv().await {
        MyTreasureOutput { current_value }.send_signal_to_dart(); // GENERATED
        current_value += 1;
    }
}
