// Execute via stdin inside the isolated kirokun-dev API container. Never reset existing answers.
if (process.env.FIREBASE_PROJECT_ID !== 'kirokun-dev' || process.env.NOTIFICATIONS_ENABLED !== 'false' || process.env.ASSIGNMENT_PREPARATION_ENABLED !== 'false') throw new Error('Isolated dev with notifications disabled is required');
const mongoose = require('mongoose');
const { Survey, Assignment } = require('/app/dist/models/survey.model');
const questions = [
  {index:0,type:'header',title:'すべての入力形式を確認',text:'開発用のテストです。全7種類の入力形式を確認できます。実際の研究データは入力しないでください。'},
  {index:1,type:'open',title:'自由入力',text:'今日の気づきを自由に入力してください。未入力でも次へ進めます。'},
  {index:2,type:'likert',title:'5件法',text:'今日の学習に満足していますか？',minAnnotation:'まったく満足していない',maxAnnotation:'とても満足している'},
  {index:3,type:'single',title:'単一選択',text:'今日もっとも使った言語を1つ選んでください。',values:['日本語','英語','その他']},
  {index:4,type:'multi',title:'複数選択',text:'今日行った活動を1つ以上選んでください。',values:['読む','聞く','話す','書く']},
  {index:5,type:'blanks',title:'空欄補充',text:'今日は _____ を学びました。',values:['単語','文法','発音']},
  {index:6,type:'slider',title:'スライダー',text:'今日の学習への集中度を選んでください。',minAnnotation:'集中できなかった',maxAnnotation:'とても集中できた'},
  {index:7,type:'duration',title:'時間入力',text:'今日の学習時間を選んでください。'},
  {index:8,type:'footer',title:'確認完了',text:'開発用の回答を保存します。実際の調査データは含めないでください。'}
];
(async () => {
  await mongoose.connect(process.env.MONGO_URL, {useNewUrlParser:true});
  for (const [suffix,title] of [['review','全入力形式の確認（利用者確認用）'],['qa','全入力形式の確認（動作テスト用）']]) {
    const name = '__dev_all_question_types_20260918_' + suffix;
    let survey = await Survey.findOne({name});
    if (!survey) survey = await Survey.create({name,title,questions});
    let assignment = await Assignment.findOne({'survey._id':survey._id,userId:'hiroki_u'});
    if (!assignment) assignment = await Assignment.create({userId:'hiroki_u',survey:survey.toObject(),publishAt:new Date(Date.now()-60000),expireAt:new Date(Date.now()+14*86400000)});
    console.log(JSON.stringify({fixture:name,assignmentId:String(assignment._id),answered:!!assignment.dataset}));
  }
  await mongoose.disconnect();
})().catch(e=>{console.error(e.message);process.exitCode=1;mongoose.disconnect();});
