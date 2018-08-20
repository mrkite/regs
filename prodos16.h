#pragma once

/**
 * @copyright 2018 Sean Kasun
 * The ProDOS 16 tool calls
 */

typedef struct {
  uint16_t call;
  const char *name;
} Prodos16;

static Prodos16 prodos16[] = {
  {0x0001, "CREATE"},
  {0x0002, "DESTROY"},
  {0x0004, "CHANGE_PATH"},
  {0x0005, "SET_FILE_INFO"},
  {0x0006, "GET_FILE_INFO"},
  {0x0008, "VOLUME"},
  {0x0009, "SET_PREFIX"},
  {0x000a, "GET_PREFIX"},
  {0x000b, "CLEAR_BACKUP_BIT"},
  {0x0010, "OPEN"},
  {0x0011, "NEWLINE"},
  {0x0012, "READ"},
  {0x0013, "WRITE"},
  {0x0014, "CLOSE"},
  {0x0015, "FLUSH"},
  {0x0016, "SET_MARK"},
  {0x0017, "GET_MARK"},
  {0x0018, "SET_EOF"},
  {0x0019, "GET_EOF"},
  {0x001a, "SET_LEVEL"},
  {0x001b, "GET_LEVEL"},
  {0x001c, "GET_DIR_ENTRY"},
  {0x0020, "GET_DEV_NUM"},
  {0x0021, "GET_LAST_DEV"},
  {0x0022, "READ_BLOCK"},
  {0x0023, "WRITE_BLOCK"},
  {0x0024, "FORMAT"},
  {0x0025, "ERASE_DISK"},
  {0x0027, "GET_NAME"},
  {0x0028, "GET_BOOT_VOL"},
  {0x0029, "QUIT"},
  {0x002a, "GET_VERSION"},
  {0x002c, "D_INFO"},
  {0x0031, "ALLOC_INTERRUPT"},
  {0x0032, "DEALLOCATE_INTERRUPT"},
  {0x0101, "Get_LInfo"},
  {0x0102, "Set_LInfo"},
  {0x0103, "Get_Lang"},
  {0x0104, "Set_Lang"},
  {0x0105, "Error"},
  {0x0106, "Set_Variable"},
  {0x0107, "Version"},
  {0x0108, "Read_Indexed"},
  {0x0109, "Init_Wildcard"},
  {0x010a, "Next_Wildcard"},
  {0x010b, "Read_Variable"},
  {0x010c, "ChangeVector"},
  {0x010d, "Execute"},
  {0x010e, "FastFile"},
  {0x010f, "Direction"},
  {0x0110, "Redirect"},
  {0x0113, "Stop"},
  {0x0114, "ExpandDevices"},
  {0x0115, "UnsetVariable"},
  {0x0116, "Export"},
  {0x0117, "PopVariables"},
  {0x0118, "PushVariables"},
  {0x0119, "SetStopFlag"},
  {0x011a, "ConsoleOut"},
  {0x011b, "SetIODevices"},
  {0x011c, "GetIODevices"},
  {0x011d, "GetCommand"},
  {0x2001, "Create"},
  {0x2002, "Destroy"},
  {0x2003, "OSShutdown"},
  {0x2004, "ChangePath"},
  {0x2005, "SetFileInfo"},
  {0x2006, "GetFileInfo"},
  {0x2007, "JudgeName"},
  {0x2008, "Volume"},
  {0x2009, "SetPrefix"},
  {0x200a, "GetPrefix"},
  {0x200b, "ClearBackup"},
  {0x200c, "SetSysPrefs"},
  {0x200d, "Null"},
  {0x200e, "ExpandPath"},
  {0x200f, "GetSysPrefs"},
  {0x2010, "Open"},
  {0x2011, "NewLine"},
  {0x2012, "Read"},
  {0x2013, "Write"},
  {0x2014, "Close"},
  {0x2015, "Flush"},
  {0x2016, "SetMark"},
  {0x2017, "GetMark"},
  {0x2018, "SetEOF"},
  {0x2019, "GetEOF"},
  {0x201a, "SetLevel"},
  {0x201b, "GetLevel"},
  {0x201c, "GetDirEntry"},
  {0x201d, "BeginSession"},
  {0x201e, "EndSession"},
  {0x201f, "SessionStatus"},
  {0x2020, "GetDevNumber"},
  {0x2024, "Format"},
  {0x2025, "EraseDisk"},
  {0x2026, "ResetCache"},
  {0x2027, "GetName"},
  {0x2028, "GetBoolVol"},
  {0x2029, "Quit"},
  {0x202a, "GetVersion"},
  {0x202b, "GetFSTInfo"},
  {0x202c, "DInfo"},
  {0x202d, "DStatus"},
  {0x202e, "DControl"},
  {0x202f, "DRead"},
  {0x2030, "DWrite"},
  {0x2031, "BindInt"},
  {0x2032, "UnbindInt"},
  {0x2033, "FSTSpecific"},
  {0x2034, "AddNotifyProc"},
  {0x2035, "DelNotifyProc"},
  {0x2036, "DRename"},
  {0x2037, "GetStdRefNum"},
  {0x2038, "GetRefNum"},
  {0x2039, "GetRefInfo"},
  {0x203a, "SetStdRefNum"}
};

#define numProdos16 (sizeof(prodos16) / sizeof(prodos16[0]))

static const char *prodos16Lookup(uint16_t call) {
  for (int i = 0; i < numProdos16; i++) {
    if (prodos16[i].call >= call) {
      if (prodos16[i].call == call)
        return prodos16[i].name;
      break;
    }
  }
  return NULL;
}
