# 저장량 증가 (OMZ 기본 50000 → 100000)
HISTSIZE=100000
SAVEHIST=100000

# OMZ 기본보다 강화된 dedupe
setopt hist_ignore_all_dups   # 새 명령이 기존 중복을 밀어냄
setopt hist_save_no_dups      # 파일에 중복 저장 안 함
setopt hist_find_no_dups      # 검색(Ctrl-R)에서 중복 숨김
setopt hist_reduce_blanks     # 명령 내 공백 정규화
