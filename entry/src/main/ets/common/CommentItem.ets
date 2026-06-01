import { ApiService } from '../network/ApiService';
import {
  CommentInfo,
} from '../models/Album';
import { router } from '@kit.ArkUI';

@Component
export struct CommentItemComponent {
  comment: CommentInfo = {
    id: '', uid: '', name: '', level: '', title: '', date: '', content: '',
    headUrl: '', like: 0, linkBookId: '', linkBookName: '', subComments: [],
  };
  index: number = 0;
  onSendReply: (commentId: string, albumId: string, text: string) => void = () => {};
  @State replyText: string = '';
  private apiService: ApiService = ApiService.getInstance();

  buildHeadUrl(): string {
    if (!this.comment.headUrl) {
      return '';
    }
    let domain = this.apiService.getImageDomain();
    return `https://${domain}${this.comment.headUrl}`;
  }

  // 点击关联漫画跳转
  onLinkClick(): void {
    if (this.comment.linkBookId) {
      router.pushUrl({
        url: 'pages/AlbumDetailPage',
        params: { albumId: parseInt(this.comment.linkBookId) || 0, albumName: this.comment.linkBookName }
      });
    }
  }

  doSendReply(): void {
    if (!this.replyText.trim()) return;
    this.onSendReply(this.comment.id, this.comment.linkBookId, this.replyText.trim());
    this.replyText = '';
  }

  build() {
    Column() {
      Row() {
        // ── 左侧：等级 + 头像 + 日期 ──
      Column() {
        Text(this.comment.level ? `Lv${this.comment.level}` : '')
          .fontSize(11)
          .fontColor('#FF5A5F')
          .width(56)
          .textAlign(TextAlign.Center)
          .height(24)

        // 头像
        if (this.buildHeadUrl()) {
          Image(this.buildHeadUrl())
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F0F0F0')
        } else {
          Image($r('app.media.ic_default_avatar'))
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F0F0F0')
        }

        Text(this.comment.date ? this.comment.date.substring(0, 10) : '')
          .fontSize(10)
          .fontColor('#BBBBBB')
          .width(56)
          .textAlign(TextAlign.Center)
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .width(60)

      // ── 右侧：用户名 + 等级 + 内容 + 操作 + 关联漫画 ──
      Column() {
        // 用户名 + 等级
        Row() {
          Text(this.comment.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          if (this.comment.level) {
            Text(`Lv${this.comment.level}`)
              .fontSize(11)
              .fontColor('#FF5A5F')
              .margin({ left: 8 })
          }

          if (this.comment.title) {
            Text(this.comment.title)
              .fontSize(11)
              .fontColor('#FF8A5C')
              .margin({ left: 4 })
          }
        }
        .width('100%')

        // 评论内容
        Text(this.comment.content)
          .fontSize(14)
          .fontColor('#333333')
          .lineHeight(22)
          .margin({ top: 6 })
          .width('100%')

        // 点赞 + 回复数
        Row() {
          Row() {
            Image($r('sys.symbol.heart'))
              .width(14)
              .height(14)
              .fillColor('#999999')
            Text(`${this.comment.like}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 3 })
          }
          .margin({ right: 16 })

          if (this.comment.subComments && this.comment.subComments.length > 0) {
            Row() {
              Image($r('sys.symbol.quote'))
                .width(14)
                .height(14)
                .fillColor('#999999')
              Text(`${this.comment.subComments.length}`)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ left: 3 })
            }
          }
        }
        .width('100%')
        .margin({ top: 6 })

        // 子评论预览 (最多显示2条)
        if (this.comment.subComments && this.comment.subComments.length > 0) {
          Column() {
            ForEach(this.comment.subComments.slice(0, 2), (sub: CommentInfo, subIdx: number) => {
              Column() {
                Row() {
                  Text(sub.name)
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#666666')
                  Text(`Lv${sub.level || ''}`)
                    .fontSize(10)
                    .fontColor('#FF8A5C')
                    .margin({ left: 4 })
                }
                Text(sub.content)
                  .fontSize(12)
                  .fontColor('#666666')
                  .lineHeight(18)
                  .margin({ top: 2 })
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
              .padding(8)
              .backgroundColor('#F8F8F8')
              .borderRadius(6)
              .margin({ top: 4 })
            }, (sub: CommentInfo) => sub.id)

            if (this.comment.subComments.length > 2) {
              Text(`...更多 ${this.comment.subComments.length - 2} 条回复`)
                .fontSize(11)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .margin({ top: 4 })
        }

        // 关联漫画
        if (this.comment.linkBookId && this.comment.linkBookName) {
          Row() {
            Image($r('sys.symbol.book'))
              .width(12)
              .height(12)
              .fillColor('#FF5A5F')
            Text(this.comment.linkBookName)
              .fontSize(11)
              .fontColor('#FF5A5F')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ left: 3 })
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor('#FFF5F5')
          .borderRadius(4)
          .margin({ top: 6 })
          .onClick(() => this.onLinkClick())
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 8 })
    }

    // 回复输入框
    Row() {
      TextInput({ placeholder: '给个回应', text: this.replyText })
        .layoutWeight(1)
        .height(36)
        .fontSize(13)
        .backgroundColor('#F5F5F5')
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => { this.replyText = value; })

      Text('发送')
        .fontSize(13)
        .fontColor('#FF5A5F')
        .padding({ left: 10, right: 4 })
        .onClick(() => this.doSendReply())
    }
    .width('100%')
    .padding({ top: 8 })
    .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }
}
