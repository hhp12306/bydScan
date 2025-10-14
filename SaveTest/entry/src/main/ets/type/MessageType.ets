export class MessageInfo {
  id?: number;
  uuid?: string;
  session_id?: string;
  type?: number;
  content?: string;
  ifSubmit?: boolean;

  constructor(id?: number, uuid?: string, session_id?: string, type?: number, content?: string, ifSubmit?: boolean) {
    this.id = id;
    this.uuid = uuid;
    this.session_id = session_id;
    this.type = type;
    this.content = content;
    this.ifSubmit = ifSubmit;
  }
}

@Observed
export class ObservedChatMessage {
  id?: number;
  uuid?: string;
  session_id?: string;
  senderId?: string;
  receiverId?: string;
  content?: string | MessageInfo;
  time?: number;
  messageType?: string;
  type?: number;
  leftOrRight?: number;
  send_from?: number;
  status?: string;
  nickname?: string;
  headimgurl?: string;
  cust_name?: string;
  ifRead?: number;
  ifSendSuccess?: number;
  loadingProgress?: number;
  messageInvalidation?: number;
  evaluate_msg?: number;
  evaluation_way?: number;
  evaluation?: string;
  evaluationResult?: string;
  chatEvalResult?: number;
  messageBoardResult?: string;
  messageBoardParams?: string;
  appid?: string;
  robot_appid?: string;

  constructor() {
    this.id = 0;
    this.uuid = '';
    this.session_id = '';
    this.senderId = '';
    this.receiverId = '';
    this.content = '';
    this.time = 0;
    this.messageType = '';
    this.type = 0;
    this.leftOrRight = 0;
    this.send_from = 0;
    this.status = '';
    this.nickname = '';
    this.headimgurl = '';
    this.cust_name = '';
    this.ifRead = 0;
    this.ifSendSuccess = 0;
    this.loadingProgress = 0;
    this.messageInvalidation = 0;
    this.evaluate_msg = 0;
    this.evaluation_way = 0;
    this.evaluation = '';
    this.evaluationResult = '';
    this.chatEvalResult = 0;
    this.messageBoardResult = '';
    this.messageBoardParams = '';
    this.appid = '';
    this.robot_appid = '';
  }
}
