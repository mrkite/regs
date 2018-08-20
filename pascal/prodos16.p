FileAccess: mask Word {
  7: destroyEnable
  6: renameEnable
  5: backupNeeded
  1: writeEnable
  0: readEnable
}

FileDate: mask Word {
  15-9: year
  8-5: month
  4-0: day
}

FileTime: mask Word {
  12-8: hour
  5-0: minute
}

StorageType: enum Word {
  inactive: $0
  seedling: $1
  sapling: $2
  tree: $3
  pascal: $4
  directory: $d
}

CREATE_PB: record {
  pathname: ^String           // 00
  access: FileAccess          // 04
  file_type: Word             // 06
  aux_type: Long              // 08
  storage_type: StorageType   // 0c
  create_date: FileDate       // 0e
  create_time: FileTime       // 10
}

DESTROY_PB: record {
  pathname: ^String   // 00
}

CHANGE_PATH_PB: record {
  pathname: ^String       // 00
  new_pathname: ^String   // 04
}

SET_FILE_INFO_PB: record {
  pathname: ^String      // 00
  access: FileAccess     // 04
  file_type: Word        // 06
  aux_type: Long         // 08
  unused: Word           // 0c
  create_date: FileDate  // 0e
  create_time: FileTime  // 10
  mod_date: FileDate     // 12
  mod_time: FileTime     // 14
}

GET_FILE_INFO_PB: record {
  pathname: ^String          // 00
  access: FileAccess         // 04
  file_type: Word            // 06
  aux_type: Long             // 08
  storage_type: StorageType  // 0c
  create_date: FileDate      // 0e
  create_time: FileTime      // 10
  mod_date: FileDate         // 12
  mod_time: FileTime         // 14
  blocks_used: Long          // 16
}

VOLUME_PB: record {
  dev_name: ^String     // 00
  vol_name: ^String     // 04
  total_blocks: Long    // 08
  free_blocks: Long     // 0c
  file_sys_id: Word     // 10
}

SET_PREFIX_PB: record {
  prefix_num: Word    // 00
  prefix: ^String     // 02
}

GET_PREFIX_PB: record {
  prefix_num: Word    // 00
  prefix: ^String     // 02
}

CLEAR_BACKUP_BIT_PB: record {
  pathname: ^String   // 00
}

OPEN_PB: record {
  ref_num: Word       // 00
  pathname: ^String   // 02
  io_buffer: Ptr      // 06
}

NEWLINE_PB: record {
  ref_num: Word       // 00
  enable_Mask: Word   // 02
  newline_char: Word  // 04
}

READ_PB: record {
  ref_num: Word         // 00
  data_buffer: Ptr      // 02
  request_count: Long   // 06
  transfer_count: Long  // 0a
}

WRITE_PB: record {
  ref_num: Word         // 00
  data_buffer: Ptr      // 02
  request_count: Long   // 06
  transfer_count: Long  // 0a
}

CLOSE_PB: record {
  ref_num: Word     // 00
}

FLUSH_PB: record {
  ref_num: Word     // 00
}

SET_MARK_PB: record {
  ref_num: Word     // 00
  position: Long    // 02
}

GET_MARK_PB: record {
  ref_num: Word     // 00
  position: Long    // 02
}

SET_EOF_PB: record {
  ref_num: Word     // 00
  eof: Long         // 02
}

GET_EOF_PB: record {
  ref_num: Word     // 00
  eof: Long         // 02
}

SET_LEVEL_PB: record {
  level: Word       // 00
}

GET_LEVEL_PB: record {
  level: Word       // 00
}

GET_DEV_NUM_PB: record {
  dev_name: ^String   // 00
  dev_num: Word       // 04
}

GET_LAST_DEV_PB: record {
  dev_num: Word     // 00
}

READ_BLOCK_PB: record {
  dev_num: Word     // 00
  data_buffer: Ptr  // 02
  block_num: Long   // 06
}

WRITE_BLOCK_PB: record {
  dev_num: Word     // 00
  data_buffer: Ptr  // 02
  block_num: Long   // 06
}

FORMAT_PB: record {
  dev_name: ^String   // 00
  vol_name: ^String   // 04
  file_sys_id: Word   // 08
}

GET_NAME_PB: record {
  data_buffer: ^String  // 00
}

GET_BOOT_VOL_PB: record {
  data_buffer: ^String  // 00
}

QUIT_PB: record {
  pathname: ^String   // 00
  flags: mask Word {  // 04
    15: returnUserID
    14: restartable
  }
}

GET_VERSION_PB: record {
  version: Word   // 00
}

ALLOC_INTERRUPT_PB: record {
  int_num: Word   // 00
  int_code: Ptr   // 02
}

DEALLOC_INTERRUPT_PB: record {
  int_num: Word   // 00
}
