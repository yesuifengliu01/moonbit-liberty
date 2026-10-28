///|
/// Self-authored constant1D INV/OR2 fixture for independent causal-witness tests.
pub fn constraint_context_library() -> String {
  let text =
    #|library (context_demo) {
    #|  delay_model : table_lookup;
    #|  time_unit : "1ns";
    #|  capacitive_load_unit (1.0, "pf");
    #|  voltage_unit : "1V";
    #|  current_unit : "1mA";
    #|  nom_process : 1;
    #|  nom_voltage : 1;
    #|  nom_temperature : 25;
    #|  input_threshold_pct_rise : 50;
    #|  input_threshold_pct_fall : 50;
    #|  output_threshold_pct_rise : 50;
    #|  output_threshold_pct_fall : 50;
    #|  slew_lower_threshold_pct_rise : 20;
    #|  slew_upper_threshold_pct_rise : 80;
    #|  slew_lower_threshold_pct_fall : 20;
    #|  slew_upper_threshold_pct_fall : 80;
    #|  slew_derate_from_library : 1;
    #|  lu_table_template (axis) { variable_1 : input_net_transition; index_1 ("0, 1"); }
    #|  cell (INV) {
    #|    area : 1;
    #|    pin (A) { direction : input; capacitance : 0; }
    #|    pin (Y) {
    #|      direction : output;
    #|      function : "!A";
    #|      timing () {
    #|        related_pin : "A"; timing_sense : negative_unate; timing_type : combinational;
    #|        cell_rise (axis) { values ("0.2, 0.2"); }
    #|        cell_fall (axis) { values ("0.2, 0.2"); }
    #|        rise_transition (axis) { values ("0.1, 0.1"); }
    #|        fall_transition (axis) { values ("0.1, 0.1"); }
    #|      }
    #|    }
    #|  }
    #|  cell (OR2) {
    #|    area : 1;
    #|    pin (A) { direction : input; capacitance : 0; }
    #|    pin (B) { direction : input; capacitance : 0; }
    #|    pin (Y) {
    #|      direction : output; function : "A | B";
    #|      timing () {
    #|        related_pin : "A"; timing_sense : positive_unate; timing_type : combinational;
    #|        cell_rise (axis) { values ("0.2, 0.2"); }
    #|        cell_fall (axis) { values ("0.2, 0.2"); }
    #|        rise_transition (axis) { values ("0.1, 0.1"); }
    #|        fall_transition (axis) { values ("0.1, 0.1"); }
    #|      }
    #|      timing () {
    #|        related_pin : "B"; timing_sense : positive_unate; timing_type : combinational;
    #|        cell_rise (axis) { values ("0.2, 0.2"); }
    #|        cell_fall (axis) { values ("0.2, 0.2"); }
    #|        rise_transition (axis) { values ("0.1, 0.1"); }
    #|        fall_transition (axis) { values ("0.1, 0.1"); }
    #|      }
    #|    }
    #|  }
    #|}
  text
}
