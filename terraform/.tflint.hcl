# tflint config. The "terraform" ruleset is bundled with tflint (no plugin
# download needed); the "recommended" preset enables its best-practice rules.
plugin "terraform" {
  enabled = true
  preset  = "recommended"
}
