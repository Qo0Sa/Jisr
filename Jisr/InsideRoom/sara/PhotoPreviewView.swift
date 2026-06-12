//
//  PhotoPreviewView.swift
//  Jisr
//

import SwiftUI

struct PhotoPreviewView: View {
    let photo: UIImage
    var onDismiss: () -> Void
    var onSave: ((String, String) -> Void)? = nil
    var isSaving: Bool = false

    @State private var thought = ""
    @State private var selectedEmoji: String? = nil
    @State private var isCardExpanded = true
    @FocusState private var isFocused: Bool

    private let emojiData: [(String, Color)] = [
        ("😰", Color(red: 0.88, green: 0.62, blue: 0.62)),
        ("😞", Color(red: 0.62, green: 0.72, blue: 0.88)),
        ("🤩", Color(red: 0.62, green: 0.82, blue: 0.68)),
        ("😊", Color(red: 0.92, green: 0.86, blue: 0.56)),
        ("😆", Color(red: 0.88, green: 0.76, blue: 0.64)),
        ("😎", Color(red: 0.76, green: 0.66, blue: 0.88)),
    ]

    private var wordCount: Int {
        thought.split(whereSeparator: \.isWhitespace).count
    }

    var body: some View {
        ZStack(alignment: .top) {
            PhotoBackground(image: photo)

            // X dismiss
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            // Bottom stack
            VStack(spacing: 14) {
                Spacer()

                if isCardExpanded {
                    VStack(alignment: .leading, spacing: 10) {
                        // Drag handle
                        HStack {
                            Spacer()
                            Capsule()
                                .fill(Color.white.opacity(0.45))
                                .frame(width: 36, height: 4)
                            Spacer()
                        }
                        .padding(.bottom, 2)
                        .gesture(
                            DragGesture(minimumDistance: 20)
                                .onEnded { value in
                                    if value.translation.height > 40 {
                                        isFocused = false
                                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                            isCardExpanded = false
                                        }
                                    }
                                }
                        )

                        // Thought input
                        ZStack(alignment: .topLeading) {
                            if thought.isEmpty {
                                Text("Type a thought ...")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $thought)
                                .focused($isFocused)
                                .font(.system(size: 14))
                                .frame(minHeight: 8, maxHeight: 40)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .tint(.white)
                        }

                        HStack {
                            Spacer()
                            Text("\(wordCount) words")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.4))
                        }

                        Divider().background(Color.white.opacity(0.2))

                        Text("How does this moment feel?")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.75))
                            .padding(.leading, 8)

                        HStack(spacing: 8) {
                            ForEach(emojiData, id: \.0) { emoji, color in
                                Button(action: {
                                    selectedEmoji = selectedEmoji == emoji ? nil : emoji
                                }) {
                                    Text(emoji)
                                        .font(.system(size: 24))
                                        .frame(width: 42, height: 42)
                                        .background(Circle().fill(color.opacity(selectedEmoji == emoji ? 1.0 : 0.65)))
                                        .overlay(Circle().stroke(Color.white.opacity(selectedEmoji == emoji ? 0.5 : 0), lineWidth: 1.5))
                                }
                            }
                        }
                        .padding(.leading, 12)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                    .padding(.horizontal, 30)
                    .padding(.bottom, 79)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Collapsed pill — tap to re-expand
                    Button(action: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            isCardExpanded = true
                        }
                    }) {
                        Capsule()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 44, height: 5)
                    }
                    .transition(.opacity)
                }

                // Confirm button (always visible)
                Button(action: {
                    guard !isSaving else { return }
                    if let onSave {
                        onSave(thought, selectedEmoji ?? "😊")
                    } else {
                        onDismiss()
                    }
                }) {
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 5)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Circle()
                                .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                                .frame(width: 68, height: 68)
                                .overlay(
                                    Group {
                                        if isSaving {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                        )
                }
                .disabled(isSaving)
                .padding(.bottom, 84)
            }
        }
        .ignoresSafeArea()
        .onTapGesture { isFocused = false }
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isCardExpanded)
    }
}
