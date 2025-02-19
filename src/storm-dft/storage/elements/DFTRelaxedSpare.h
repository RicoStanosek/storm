#pragma once

#include "DFTSpare.h"

namespace storm::dft {
namespace storage {
namespace elements {

/*!
 * Relaxed SPARE gate - behaves like a normal SPARE gate but when a claimed child fails,
 * it non-deterministically chooses between claiming another spare or staying failed.
 */
template<typename ValueType>
class DFTRelaxedSpare : public DFTSpare<ValueType> {
   public:
    /*!
     * Constructor.
     * @param id Id.
     * @param name Name.
     * @param children Children.
     */
    DFTRelaxedSpare(size_t id, std::string const& name, std::vector<std::shared_ptr<DFTElement<ValueType>>> const& children = {})
        : DFTSpare<ValueType>(id, name, children) {
        // Intentionally left empty.
    }

    std::shared_ptr<DFTElement<ValueType>> clone() const override {
        return std::shared_ptr<DFTElement<ValueType>>(new DFTRelaxedSpare<ValueType>(this->id(), this->name(), {}));
    }

    storm::dft::storage::elements::DFTElementType type() const override {
        return storm::dft::storage::elements::DFTElementType::RELAXED_SPARE;
    }

    void checkFails(storm::dft::storage::DFTState<ValueType>& state, storm::dft::storage::DFTStateSpaceGenerationQueues<ValueType>& queues) const override {
        if (state.isOperational(this->id())) {
            size_t uses = state.uses(this->id());
            if (!state.isOperational(uses)) {
                // Try to claim new spare - just like normal SPARE gate
                bool claimingSuccessful = state.claimNew(this->id(), uses, this->children());
                if (!claimingSuccessful) {
                    this->fail(state, queues);
                }
            }
        }
    }
};

}  // namespace elements
}  // namespace storage
}  // namespace storm::dft