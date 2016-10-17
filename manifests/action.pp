# == Define: curator::action
#
# Installs a cronjob for a specific action
#
# === Parameters
#
# [*name*]
#   String.  Valid values: Alias, Allocation, Close, Create Index, Delete Indices, Delete Snapshots,
#            Open, forceMerge, Replicas, Restore, Snapshot 
#   Default:
#
# [*description*]
#   String.  Description for the action
#   Default: ''
#
# [*allocation_type*]
#   String.  Read more about these settings at http://www.elastic.co/guide/en/elasticsearch/reference/current/shard-allocation-filtering.html
#   Default: undef
#
# [*continue_if_exception*]
#   Boolean. If continue_if_exception is set to True, Curator will attempt to continue on to the next action,
#            if anymore, even if an exception is encountered. Curator will log but ignore the exception that was raised.
#   Default: 'False'
#
# [*count*]
#   Number.  The value for this setting is the number of replicas to assign to matching indices.
#   Default: undef
#
# [*delay*]
#   Number.  The value for this setting is the number of seconds to delay between forceMerging indices, to allow the cluster to quiesce.
#   Default: undef
#
# [*delete_aliases*]
#   Number.  The value for this setting determines whether aliases will be deleted from indices before closing.
#   Default: undef
#
# [*disable_action*]
#   Boolean. If disable_action is set to True, Curator will ignore the current action.
#            This may be useful for temporarily disabling actions in a large configuration file.
#   Default: False
#
# [*ignore_empty_list*]
#   Boolean. Depending on your indices, and how you’ve filtered them, an empty list may be presented to the action.
#            This results in an error condition.
#   Default: False
#
#  ___TBC___
#
# [*filters*]
#   Array.   Array of hashes
#   Default: []
define curator::action (
  $action                = $name,
  $description           = $name,
  $allocation_type       = undef,
  $continue_if_exception = 'False',
  $count                 = undef,
  $delay                 = undef,
  $delete_aliases        = undef,
  $disable_action        = 'False',
  # $extra_settings = undef, #We don't support $extra_settings yet
  $ignore_empty_list     = 'False',
  $ignore_unavailable    = undef,
  $include_aliases       = undef,
  $include_global_state  = undef,
  $indices               = undef,
  $key                   = undef,
  $max_num_segments      = undef,
  $option_name           = undef,
  $partial               = undef,
  $rename_pattern        = undef,
  $rename_replacement    = undef,
  $repository            = undef,
  $retry_count           = undef,
  $retry_interval        = undef,
  $skip_repo_fs_check    = undef,
  $timeout_override      = undef,
  $value                 = undef,
  $wait_for_completion   = undef,
  $filters               = [],
  $order                 = 1,
){
  include ::curator

  if !member([
    'alias',
    'allocation',
    'close',
    'create_index',
    'delete_indices',
    'delete_snapshots',
    'open',
    'forcemerge',
    'replicas',
    'restore',
    'snapshot',
    ], $action) {
    fail("Incorrect action name: ${$action}, Check https://www.elastic.co/guide/en/elasticsearch/client/curator/current/actions.html")
  }

  if ($allocation_type and $action != 'alias') or ( $allocation_type and !validate_re($allocation_type, '^(require|include|exclude)$')) {
    fail('$allocation_type can be set only for action = alias')
  }

  if $count and $action != 'replicas' {
    fail('$count can be set only for action = replicas')
  }

  if ($delay or $max_num_segments) and $action != 'forcemerge' {
    fail('$delay can be set only for action = forcemerge')
  }

  if $delete_aliases and $action != 'close' {
    fail('$delete_aliases can be set only for action = close')
  }

  if ($include_aliases or $indices or $rename_pattern or $rename_replacement) and $action != 'restore' {
    fail('$include_aliases can be set only for action = restore')
  }

  if ($include_global_state or $ignore_unavailable or $partial or $skip_repo_fs_check) and $action != 'snapshot' {
    fail('$include_global_state can be set only for action = snapshot')
  }

  if ($key or $value) and $action != 'allocation' {
    fail('$key can be set only for action = allocation')
  }

  if $repository and !member(['delete_snapshots', 'snapshot',], $action) {
    fail('$repository can be set only for action = delete_snapshots or snapshot')
  }

  if ($retry_count or $retry_interval) and $action != 'delete_snapshots' {
    fail('$retry_count can be set only for action = delete_snapshots')
  }

  if $wait_for_completion and !member(['allocation', 'replicas', 'restore', 'snapshot'], $action) {
    fail('$wait_for_completion can be set only for action = allocation or replicas or restore or snapshot')
  }

  concat::fragment { "${name}_action":
    target  => $curator::actions_file,
    content => template("${module_name}/action.erb"),
    order   => "${order}_${name}",
  }
}
