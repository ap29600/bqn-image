⟨FromPNM⟩ ⇐

ReadNat     ← 10⊸×⊸+˜´∘⌽-⟜48
Part        ← (¯1+⊢×·+`>⟜»)⊸⊔
IsNum       ← ('0'-@)⊸≤∧≤⟜('9'-@)
FillReshape ← {𝕨⥊(×´𝕨)↑𝕩∾0}

# NOTE: the plain text formats allow comments to appear the middle of tokens
# without breaking them, so it's fine to remove the comments from the bulk of
# the data without worrying about tokens merging.
RemoveComments ← {
  nl ← (≠𝕩)∾˜/10=𝕩
  c ← /('#'-@)=𝕩
  m ← ¯1⊸»⊸≠ i ← nl⍋c
  𝕩/˜ 1+`(1+nl⊏˜m/i)-○((≠𝕩)↑/⁼)m/c
}

_readRawData ← {
  w‿h‿lv𝕗_𝕣𝕩:
  pd ← (h‿w∾𝕗)FillReshape(lv≥256)◶⟨⊢, +´˘256‿1×⎉1↑‿2⊸⥊⟩𝕩
  pd‿lv
}

_readAsciiData ← {
  w‿h‿lv𝕗_𝕣𝕩:
  pd ← (h‿w∾𝕗)FillReshape ReadNat¨IsNum⊸Part 𝕩
  pd‿lv
}

ReadAsciiBoolData ← {
  w‿h‿lv𝕊𝕩:
  pd ← h‿w FillReshape(m∨('0'-@)=𝕩)/m←('1'-@)=𝕩
  pd‿lv
}

ReadRawBoolData ← {
  w‿h‿lv𝕊𝕩:
  pd ← h‿w FillReshape ⥊⌽˘∘‿8⥊⟨8,1‿'u'⟩•bit._cast 𝕩
  pd‿lv
}

ReadTokens ← {
  toks ← ⟨⟩
  tok ← ⟨⟩
  comment ← 0
  rest ← {toks∾↩ReadNat⎊0 tok ⋄ tok↩⟨⟩ ⋄ 𝕩}∘{
    0=≠𝕩?          𝕩;
    ('#'-@)=⊑𝕩?    comment↩1 ⋄ 𝕊1↓𝕩; # initiate new comment
    comment∧10=⊑𝕩? comment↩0 ⋄ 𝕊1↓𝕩; # newline terminates comments
    comment?       𝕊1↓𝕩;
    IsNum⊑𝕩?       tok∾↩⊏𝕩 ⋄ 𝕊1↓𝕩;
    0=≠tok?        𝕊1↓𝕩; # continue looking
    1↓𝕩 # token is formed. consume the breaking character and return.
  }⍟𝕨 𝕩
  toks‿rest
}

# Lookup table for file types.
magic_bytes‿header_procs‿data_procs ← <˘⍉[
  ⟨"P1"-@, ((∾⟜1⌾⊑)2⊸ReadTokens), ReadAsciiBoolData⟜RemoveComments⟩,
  ⟨"P2"-@, (       3⊸ReadTokens), ⟨ ⟩_readAsciiData⟜RemoveComments⟩,
  ⟨"P3"-@, (       3⊸ReadTokens), ⟨3⟩_readAsciiData⟜RemoveComments⟩,
  ⟨"P4"-@, ((∾⟜1⌾⊑)2⊸ReadTokens), ReadRawBoolData                 ⟩,
  ⟨"P5"-@, (       3⊸ReadTokens), ⟨ ⟩_readRawData                 ⟩,
  ⟨"P6"-@, (       3⊸ReadTokens), ⟨3⟩_readRawData                 ⟩
]

FromPNM ⇐ {
  mb‿f ← 2(↑⋈↓)𝕩-@
  i←⊑magic_bytes⊐⋈mb
  ⟨@+mb⟩∾˜ i◶data_procs´ i◶header_procs f
}
